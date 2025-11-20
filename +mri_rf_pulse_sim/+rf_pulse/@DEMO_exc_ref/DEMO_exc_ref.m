classdef DEMO_exc_ref < mri_rf_pulse_sim.backend.rf_pulse.abstract

    properties (GetAccess = public, SetAccess = public)
        crusher_dephasing    mri_rf_pulse_sim.ui_prop.scalar               % [rad] dephasing induced by the crusher gradient
        crusher_duration     mri_rf_pulse_sim.ui_prop.scalar               % [s] crusher gradient duration
        TE                   mri_rf_pulse_sim.ui_prop.scalar               % [s] delay between EXC and REF is TE/2
    end % props

    properties (GetAccess = public, SetAccess = protected)
        exc                  mri_rf_pulse_sim.rf_pulse.slr
        ref                  mri_rf_pulse_sim.rf_pulse.slr
    end % props

    methods (Access = public)

        % constructor
        function self = DEMO_exc_ref()
            warning('!!! NOT A PULSE !!! mostly for demonstration purpose')

            self.exc = mri_rf_pulse_sim.rf_pulse.slr();
            self.exc.parent = self; % this allows the automatic GUI update
            self.exc.pulse_type.value = "ex";
            self.exc.filter_type.value = "ls";
            self.exc.duration.set(2e-3);
            self.exc.gz_rewinder.setTrue();

            self.ref = mri_rf_pulse_sim.rf_pulse.slr();
            self.ref.parent = self; % this allows the automatic GUI update
            self.ref.pulse_type.value = "se";
            self.ref.filter_type.value = "ls";
            self.ref.flip_angle.set(180);
            self.ref.rf_phase.set(90);
            self.ref.slice_thickness.set(self.exc.slice_thickness*2);

            self.crusher_dephasing    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='crusher_dephasing', value=  8*pi, unit='rad', scale=1/pi);
            self.crusher_duration     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='crusher_duration' , value=  1e-3, unit='ms' , scale=1e3 );
            self.TE                   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='TE'               , value= 15e-3, unit='ms' , scale=1e3 );

            self.generate_DEMO_exc_ref();
        end % fcn

        function generate(self) % #abstract
            self.generate_DEMO_exc_ref();
        end % fcn

        function generate_DEMO_exc_ref(self)

            % prep pulses
            exc_rewinder = self.exc.gz_rewinder.get();
            self.exc.gz_rewinder.setFalse();
            self.exc.generate();
            self.exc.gz_rewinder.set(exc_rewinder);
            self.ref.generate();


            % prep timings and index
            self.duration.value = self.get_DEMO_ref_duration();
            self.time = linspace(-self.exc.duration/2, self.TE.get(), (self.exc.n_points+self.ref.n_points)*2);
            exc_idx = self.time < self.exc.duration/2;
            rew_idx = (self.time >= self.exc.duration/2) & (self.time <= self.exc.duration*1);
            ref_idx = (self.time >= self.TE/2-self.ref.duration/2) & (self.time <= self.TE/2+self.ref.duration/2);

            exc__time = linspace(-self.exc.duration/2, +self.exc.duration/2, sum(exc_idx));
            ref__time = linspace(-self.ref.duration/2, +self.ref.duration/2, sum(ref_idx));

            exc__waveform = interp1(self.exc.time,self.exc.B1, exc__time, 'spline');
            ref__waveform = interp1(self.ref.time,self.ref.B1, ref__time, 'spline');

            exc__grad     = interp1(self.exc.time,self.exc.GZ, exc__time, 'spline');
            ref__grad     = interp1(self.ref.time,self.ref.GZ, ref__time, 'spline');

            self.B1 = zeros(size(self.time));
            self.GZ = zeros(size(self.time));

            self.B1(exc_idx) = self.B1(exc_idx) + exc__waveform;
            self.GZ(exc_idx) = self.GZ(exc_idx) + exc__grad;
            if self.exc.gz_rewinder
                [~,waveform_max_idx] = max(abs(exc__waveform));
                asymmetry = 1 - (waveform_max_idx / length(exc__waveform));
                self.GZ(rew_idx) = self.GZ(rew_idx) -exc__grad(1:sum(rew_idx)) * (asymmetry/0.5); % quick and dirty way to have correct phase
            end
            self.B1(ref_idx) = self.B1(ref_idx) + ref__waveform;
            self.GZ(ref_idx) = self.GZ(ref_idx) + ref__grad;

            % prep crushers
            crusher_moment = self.crusher_dephasing / (self.gamma * self.exc.slice_thickness);
            crusher_ampl   = crusher_moment / self.crusher_duration;
            crusher_L_idx  = (self.time > self.TE/2-self.ref.duration/2-self.crusher_duration) & (self.time < self.TE/2-self.ref.duration/2);
            crusher_R_idx  = (self.time > self.TE/2+self.ref.duration/2) & (self.time < self.TE/2+self.ref.duration/2+self.crusher_duration);
            self.GZ(crusher_L_idx) = self.GZ(crusher_L_idx) + crusher_ampl;
            self.GZ(crusher_R_idx) = self.GZ(crusher_R_idx) + crusher_ampl;
        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.exc.get_bandwidth();
        end % fcn

        function txt = summary(self) % #abstract
            txt = '';
        end % fcn

        function init_base_gui(self, container) % override abstract class
            pos_exc = [0.00 0.00 0.50 1.00];
            pos_ref = [0.50 0.00 0.50 1.00];

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

            self.ref.gz_rewinder.visible = "off";

            self.exc.init_base_gui(panel_exc);
            self.ref.init_base_gui(panel_ref);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_exc = [0.00 0.00 0.37 1.00];
            pos_ref = [0.37 0.00 0.37 1.00];
            pos_oth = [0.75 0.00 0.25 1.00];

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

            self.exc.init_specific_gui(panel_exc);
            self.ref.init_specific_gui(panel_ref);

            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                panel_oth,...
                [self.crusher_dephasing, self.crusher_duration, self.TE]...
                );
        end % fcn

    end % meths

    methods(Access = protected)

        function value = get_DEMO_ref_duration(self)
            value = self.TE + self.exc.duration/2;
        end % fcn

    end % meths

end % class
