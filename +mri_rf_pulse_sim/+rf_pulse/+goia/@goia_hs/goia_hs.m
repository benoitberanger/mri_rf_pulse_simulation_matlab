classdef goia_hs < mri_rf_pulse_sim.rf_pulse.foci

    properties (GetAccess = public, SetAccess = public)

        f mri_rf_pulse_sim.ui_prop.scalar
        n mri_rf_pulse_sim.ui_prop.scalar
        m mri_rf_pulse_sim.ui_prop.scalar

    end % props

    methods (Access = public)

        function self = goia_hs()
            self@mri_rf_pulse_sim.rf_pulse.foci(); % call HS constructor
            self.f = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='f', value=0.9);
            self.n = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n', value=4);
            self.m = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='m', value=2);
            self.n_points.value = 512;
            self.beta.value = 5;
            self.mu.value = 2000;
            self.generate_goia_hs();
        end % fcn

        function generate(self)
            self.generate_goia_hs();
        end % fcn

        function generate_goia_hs(self)
            self.time = linspace(0, self.duration, self.n_points);

            T = (2*self.time / self.duration) - 1;

            self.amplitude_modulation = self.A0       * sech(self.beta * T.^self.n.value);
            self. gradient_modulation = self.gz       * (1 - self.f * sech(self.beta * T.^self.m.value));
            self.frequency_modulation = cumsum(self.amplitude_modulation.^2 ./ self.gradient_modulation) * self.duration / self.n_points;
            self.frequency_modulation = self.frequency_modulation - self.frequency_modulation(round(end/2));
            self.frequency_modulation = self.frequency_modulation .* self.gradient_modulation;
            self.frequency_modulation = self.frequency_modulation / max(abs(self.frequency_modulation)) * self.mu / 2;
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.A0, self.beta, self.mu, self.f self.gz self.n self.m]...
                );
        end % fcn

    end % meths

end % class
