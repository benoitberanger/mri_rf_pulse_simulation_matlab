classdef foci < mri_rf_pulse_sim.rf_pulse.hs

    % Payne GS, Leach MO. Implementation and evaluation of frequency offset
    % corrected inversion (FOCI) pulses on a clinical MR system. Magn Reson
    % Med. 1997 Nov;38(5):828-33. doi: 10.1002/mrm.1910380520. PMID: 9358458.

    properties (GetAccess = public, SetAccess = protected, Dependent)
        A (1,:) double % C-shape
    end % props

    methods % no attribute for dependent properies

        function  value = get.A(self)
            value = 10 * ones(size(self.time));

            cond1 = sech(self.beta*self.time) >  0.1;
            value(cond1) = 1 ./ sech(self.beta*self.time(cond1));

            cond2 = cosh(self.beta*self.time) < 10.0;
            value(cond2) = cosh(self.beta*self.time(cond2));
        end % fcn

    end % meths

    methods (Access = public)

        function self = foci()
            self@mri_rf_pulse_sim.rf_pulse.hs(); % call HS constructor

            % set parameters like in the article
            self.n_points.value = 4096;
            self.duration.value = 7.68 * 1e-3;
            self.A0.value = 100 * 1e-6; % this B1max is not in the article, but I still need to set it with reasonable value
            self.beta.value = 1618;
            BW = 2000; % Hz
            self.mu.value = BW * pi / self.beta;
            self.gz.value = 2.5 * 1e-3;

            self.generate_foci();
        end % fcn

        function generate(self)
            self.generate_foci();
        end % fcn

        function generate_foci(self)
            self.generate_hs();
            self.amplitude_modulation = self.A .* self.amplitude_modulation;
            self.frequency_modulation = self.A .* self.frequency_modulation;
            self. gradient_modulation = self.A .* self. gradient_modulation;
        end % fcn


    end % meths


end % class
