classdef sinc_exc_ref < mri_rf_pulse_sim.backend.rf_pulse.abstract

    properties (GetAccess = public, SetAccess = public)
        exc__n_side_lobs mri_rf_pulse_sim.ui_prop.scalar                   % [] number of side lobs, from 1 to +Inf
        exc__flip_angle  mri_rf_pulse_sim.ui_prop.scalar                   % [deg] flip angle
        exc__rf_phase    mri_rf_pulse_sim.ui_prop.scalar                   % [deg] phase of the pulse (typically used for spoiling)
        exc__duration    mri_rf_pulse_sim.ui_prop.scalar                   % [s] duration of the excitation pulse

        ref__n_side_lobs mri_rf_pulse_sim.ui_prop.scalar                   % [] number of side lobs, from 1 to +Inf
        ref__flip_angle  mri_rf_pulse_sim.ui_prop.scalar                   % [deg] flip angle
        ref__rf_phase    mri_rf_pulse_sim.ui_prop.scalar                   % [deg] phase of the pulse (typically used for spoiling)
        ref__duration    mri_rf_pulse_sim.ui_prop.scalar                   % [s] duration of the refocusing pulse

        TE               mri_rf_pulse_sim.ui_prop.scalar                   % [s] delay between EXC and REF is TE/2
    end % props

    methods (Access = public)

        % constructor
        function self = sinc_exc_ref()
            warning('!!! EXPIRIMENTAL !!!')

            self.exc__n_side_lobs    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_side_lobs', value= 2                          );
            self.exc__flip_angle     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle' , value= 90   , unit='°'            );
            self.exc__rf_phase       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='rf_phase'   , value=  0   , unit='°'            );
            self.exc__duration       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='duration'   , value=  3e-3, unit='ms', scale=1e3);
            self.ref__n_side_lobs    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_side_lobs', value= 2                          );
            self.ref__flip_angle     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle' , value=180   , unit='°'            );
            self.ref__rf_phase       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='rf_phase'   , value= 90   , unit='°'            );
            self.ref__duration       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='duration'   , value=  3e-3, unit='ms', scale=1e3);
            self.TE                  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='TE'         , value= 15e-3, unit='ms', scale=1e3);

            self.n_points.value = 256;
            % special duration : not directly an input parameter
            self.duration.editable   = "off";
            self.duration.value      = self.get_exc_ref_duration();

            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_sinc_exc_ref();
        end % fcn

        function generate_sinc_exc_ref(self)
            self.duration.value = self.get_exc_ref_duration();
            self.time = linspace(-self.exc__duration/2, self.TE.get(), self.n_points.get());
            exc_idx = self.time < self.exc__duration/2;
            rew_idx = (self.time >= self.exc__duration/2) & (self.time <= self.exc__duration*1);
            ref_idx = (self.time >= self.TE/2-self.ref__duration/2) & (self.time <= self.TE/2+self.ref__duration/2);

            exc__time = linspace(-self.exc__duration/2, +self.exc__duration/2, sum(exc_idx));
            ref__time = linspace(-self.ref__duration/2, +self.ref__duration/2, sum(ref_idx));

            exc__lob_size = 1/self.get_sinc_exc_bandwidth;
            ref__lob_size = 1/self.get_sinc_ref_bandwidth;

            exc__waveform = Sinc(exc__time/exc__lob_size); % base shape
            exc__waveform = exc__waveform / trapz(exc__time, exc__waveform); % normalize integral
            exc__waveform = exc__waveform * deg2rad(self.exc__flip_angle.get()) / self.gamma; % scale integrale with flip angle
            exc__waveform = exc__waveform * exp(1j * deg2rad(self.exc__rf_phase.get()));

            ref__waveform = Sinc(ref__time/ref__lob_size); % base shape
            ref__waveform = ref__waveform / trapz(ref__time, ref__waveform); % normalize integral
            ref__waveform = ref__waveform * deg2rad(self.ref__flip_angle.get()) / self.gamma; % scale integrale with flip angle
            ref__waveform = ref__waveform * exp(1j * deg2rad(self.ref__rf_phase.get()));

            exc__grad = ones(size(exc__time)) * 2*pi*self.get_sinc_exc_bandwidth() / (self.gamma*self.slice_thickness);
            ref__grad = ones(size(ref__time)) * 2*pi*self.get_sinc_ref_bandwidth() / (self.gamma*self.slice_thickness);

            self.B1 = zeros(size(self.time));
            self.GZ = zeros(size(self.time));

            self.B1(exc_idx) = exc__waveform;
            self.GZ(exc_idx) = exc__grad;
            self.GZ(rew_idx) = -exc__grad(1:sum(rew_idx));
            self.B1(ref_idx) = ref__waveform;
            self.GZ(ref_idx) = ref__grad;
        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = mean([self.get_sinc_exc_bandwidth() self.get_sinc_ref_bandwidth()]);
        end % fcn

        function value = get_sinc_exc_bandwidth(self)
            value = (2*self.exc__n_side_lobs) / self.exc__duration;
        end % fcn
        function value = get_sinc_ref_bandwidth(self)
            value = (2*self.ref__n_side_lobs) / self.ref__duration;
        end % fcn

        function txt = summary(self) % #abstract
            txt = '';
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_exc = [0.00 0.20 0.50 0.80];
            pos_ref = [0.50 0.20 0.50 0.80];
            pos_oth = [0.00 0.00 1.00 0.20];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_exc = uipanel(container,...
                'Title','exc',...
                'Units','Normalized',...
                'Position',pos_exc,...
                'BackgroundColor',fig_col.figureBG);
            panel_ref = uipanel(container,...
                'Title','ref',...
                'Units','Normalized',...
                'Position',pos_ref,...
                'BackgroundColor',fig_col.figureBG);
            panel_oth = uipanel(container,...
                'Title','',...
                'Units','Normalized',...
                'Position',pos_oth,...
                'BackgroundColor',fig_col.figureBG);

            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                panel_exc,...
                [self.exc__n_side_lobs, self.exc__flip_angle, self.exc__rf_phase, self.exc__duration]...
                );
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                panel_ref,...
                [self.ref__n_side_lobs, self.ref__flip_angle, self.ref__rf_phase, self.ref__duration]...
                );

            self.TE.add_uicontrol(panel_oth)
        end % fcn

    end % meths

    methods(Access = protected)

        function value = get_exc_ref_duration(self)
            value = self.TE + self.exc__duration/2;
        end % fcn

    end % meths

end % class

function y = Sinc(x)
i    = find(x==0);        % identify the zeros
x(i) = 1;                 % fix the DIVIDED_BY_ZERO problem
y    = sin(pi*x)./(pi*x); % generate the Sinc curve
y(i) = 1;                 % fix the DIVIDED_BY_ZERO problem
end % fcn
