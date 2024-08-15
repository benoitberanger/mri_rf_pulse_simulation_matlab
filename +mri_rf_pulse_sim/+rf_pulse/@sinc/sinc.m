classdef sinc < mri_rf_pulse_sim.backend.rf_pulse.abstract

    properties (GetAccess = public, SetAccess = public)
        n_side_lobs mri_rf_pulse_sim.ui_prop.scalar                        % [] number of side lobs, from 1 to +Inf
        flip_angle  mri_rf_pulse_sim.ui_prop.scalar                        % [deg] flip angle
        rf_phase    mri_rf_pulse_sim.ui_prop.scalar                        % [deg] phase of the pulse (typically used for spoiling)

        window      mri_rf_pulse_sim.ui_prop.window                        % apply a window to the base Sinc waveform
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
    end % props

    methods % no attribute for dependent properties
        function value = get.bandwidth(self)
            value = (2*self.n_side_lobs) / self.duration;
        end% % fcn
        function set.window(self,value)
            self.window = value;
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = sinc()
            self.n_points.value = 128;
            self.n_side_lobs    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_side_lobs', value= 2          );
            self.flip_angle     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle' , value=90, unit='°');
            self.rf_phase       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='rf_phase'   , value= 0, unit='°');
            self.window         = mri_rf_pulse_sim.ui_prop.window(parent=self, name='apodization', value=''          );
            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_sinc();
            self.add_gz_rewinder();
        end % fcn

        function generate_sinc(self)
            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());

            lob_size = 1/self.bandwidth;

            waveform = Sinc(self.time/lob_size); % base shape
            waveform = waveform .* self.window.getShape(self.time); % windowing
            waveform = waveform / trapz(self.time, waveform); % normalize integral
            waveform = waveform * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.B1  = waveform * exp(1j * deg2rad(self.rf_phase.get()));
            self.GZ  = ones(size(self.time)) * self.GZavg;
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s] : n_side_lobs=%s  flip_angle=%s  rf_phase=%s  window=%s',...
                mfilename, self.n_side_lobs.repr, self.flip_angle.repr, self.rf_phase.repr, self.window.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n_side_lobs, self.flip_angle self.rf_phase],...
                [0.00 0.20 1.00 0.80]...
                );

            self.window.add_uicontrol( ...
                container, ...
                [0.00 0.00 1.00 0.20])
        end % fcn

    end % meths

    methods(Access = protected)

        function callback_open_window_gui(self,varargin)
            self.app.open_window_gui();
        end % fcn

    end % meths

end % class

function y = Sinc(x)
i    = find(x==0);        % identify the zeros
x(i) = 1;                 % fix the DIVIDED_BY_ZERO problem
y    = sin(pi*x)./(pi*x); % generate the Sinc curve
y(i) = 1;                 % fix the DIVIDED_BY_ZERO problem
end % fcn
