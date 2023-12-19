classdef foci < mri_rf_pulse_sim.rf_pulse.hs
    % Frequency Offset Corrected Inversion

    % Payne GS, Leach MO. Implementation and evaluation of frequency offset
    % corrected inversion (FOCI) pulses on a clinical MR system. Magn Reson
    % Med. 1997 Nov;38(5):828-33. doi: 10.1002/mrm.1910380520. PMID: 9358458.

    properties (GetAccess = public, SetAccess = protected, Dependent)
        A (1,:) double % C-shape
    end % props

    methods % no attribute for dependent properties

        function  value = get.A(self)
            value = 10 * ones(size(self.time));

            conditon = cosh(self.beta*self.time) < 10.0;
            value(conditon) = cosh(self.beta*self.time(conditon));
        end % fcn

    end % meths

    methods (Access = public)

        function self = foci()
            self.generate_foci();
        end % fcn

        function generate(self)
            self.generate_foci();
        end % fcn

        function generate_foci(self)
            self.generate_hs();

            % apply C-shape
            magnitude_Cshaped = self.A .* self.magnitude;
            freqmod_Cshaped = self.A .* self.FM;
            phase_from_freqmod_Cshaped = self.freq2phase(freqmod_Cshaped);
            self.B1 = magnitude_Cshaped .* exp(1j * phase_from_freqmod_Cshaped);
            self.GZ = self.GZavg / mean(self.A) * self.A;
        end % fcn

    end % meths

end % class
