classdef foci < mri_rf_pulse_sim.rf_pulse.hs
    % Frequency Offset Corrected Inversion

    % Payne GS, Leach MO. Implementation and evaluation of frequency offset
    % corrected inversion (FOCI) pulses on a clinical MR system. Magn Reson
    % Med. 1997 Nov;38(5):828-33. doi: 10.1002/mrm.1910380520. PMID: 9358458.

    properties (GetAccess = public, SetAccess = protected, Dependent)
        Cshape (1,:) double
    end % props

    methods % no attribute for dependent properties

        function  value = get.Cshape(self)
            % This is the C-shape, that will be used to modulate the amplitude, frequency and gradient
            value = 10 * ones(size(self.time));

            conditon = cosh(self.beta*self.time) < 10.0;
            value(conditon) = cosh(self.beta*self.time(conditon));
        end % fcn

    end % meths

    methods (Access = public)

        function self = foci()
            self.generate_foci();
        end % fcn

        function generate(self) % #abstract
            self.generate_foci();
        end % fcn

        function generate_foci(self)
            % FOCI is derived from HS
            % First call HS generator, then apply C-shape.
            
            self.generate_hs();

            magnitude_Cshaped = self.Cshape .* self.magnitude;
            freqmod_Cshaped   = self.Cshape .* self.FM;
            phase_from_freqmod_Cshaped = self.freq2phase(freqmod_Cshaped);
            self.B1 = magnitude_Cshaped .* exp(1j * phase_from_freqmod_Cshaped);
            self.GZ = self.GZavg / mean(self.Cshape) * self.Cshape;
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  BW=%gHz  Amax=%s  beta=%s  mu=%s',...
                mfilename, self.bandwidth, self.Amax.repr, self.beta.repr, self.mu.repr);
        end % fcn

        % init_specific_gui : use the same as in HS  % #abstract
        
    end % meths

end % class
