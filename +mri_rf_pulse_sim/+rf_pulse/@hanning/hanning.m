classdef hanning < mri_rf_pulse_sim.backend.rf_pulse.abstract

    properties (GetAccess = public, SetAccess = public)
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle
    end % props

    methods (Access = public)

        % constructor
        function self = hanning()
            self.n_points.value = 32;
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=90, unit='°');
            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_hanning();
        end % fcn

        function generate_hanning(self)
            self.assert_nonempty_prop({'n_points', 'duration','flip_angle'})

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());

            waveform = 0.5 + 0.5*cos(2*pi*self.time/self.duration);

            waveform = waveform / trapz(self.time, waveform); % normalize integral
            waveform = waveform * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.B1  = waveform;
            self.GZ  = ones(size(self.time)) * self.GZavg;
        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_hanning_bandwidth();
        end % fcn

        function value = get_hanning_bandwidth(self)
            value = 2 /self.duration;
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  flip_angle=%s',...
                mfilename, self.flip_angle.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.flip_angle],...
                [0 0 1 1]...
                );
        end % fcn

    end % meths

end % class
