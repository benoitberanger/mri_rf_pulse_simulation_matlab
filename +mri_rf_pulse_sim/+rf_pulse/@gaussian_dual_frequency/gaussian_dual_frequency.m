classdef gaussian_dual_frequency < mri_rf_pulse_sim.rf_pulse.gaussian

    methods (Access = public)

        % constructor
        function self = gaussian_dual_frequency()
            self.frequency_offcet.set(1000);
            self.generate_gaussian_dual_frequency();
        end % fcn

        function generate_gaussian_dual_frequency(self)
            self.generate_gaussian();
            self.B1 = self.Ag * exp(-self.time.^2/(2*self.sigma^2)) .* sin(2*pi*self.frequency_offcet*self.time) * 2;
        end % fcn

        function generate(self) % #abstract
            self.generate_gaussian_dual_frequency();
        end % fcn

    end % meths

end % class
