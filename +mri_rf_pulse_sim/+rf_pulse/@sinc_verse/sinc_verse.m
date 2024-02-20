classdef sinc_verse < mri_rf_pulse_sim.rf_pulse.sinc & mri_rf_pulse_sim.backend.rf_pulse.verse

    methods (Access = public)

        % constructor
        function self = sinc_verse()
            self.generate_sinc_verse();
        end % fcn

        function generate(self) % #abstract
            self.generate_sinc_verse();
        end % fcn

        function generate_sinc_verse(self)
            self.generate_sinc();
            self.verse_rand();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.sinc(self);
            txt = strrep(txt,'[sinc]', sprintf('[%s::rand]',mfilename));
        end % fcn

    end % meths

end % class
