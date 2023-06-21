classdef goia < mri_rf_pulse_sim.rf_pulse.foci

    properties (GetAccess = public, SetAccess = public)

        n mri_rf_pulse_sim.ui_prop.scalar
        m mri_rf_pulse_sim.ui_prop.scalar

    end % props

    methods (Access = public)

        function self = goia()
            self@mri_rf_pulse_sim.rf_pulse.foci(); % call HS constructor
            self.n = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n', value=4);
            self.m = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='m', value=2);
            self.n_points.value = 512;
            self.beta.value = 5;
            self.mu.value = 1000;
            self.gz.value = 20 * 1e-3;
            self.generate_goia();
        end % fcn

        function generate(self)
            self.generate_goia();
        end % fcn

        function generate_goia(self)
            self.time = linspace(0, self.duration, self.n_points);

            T = (2*self.time / self.duration) - 1;

            self.amplitude_modulation = self.A0       * sech(self.beta * T.^self.n.value);
            self. gradient_modulation = self.gz       * (1 - 0.9 * sech(self.beta * T.^self.m.value));
            self.frequency_modulation = self.mu.value * tanh(self.beta * T.^(self.n.value-1));

        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.A0, self.beta, self.mu, self.gz self.n self.m]...
                );
        end % fcn

    end % meths

end % class
