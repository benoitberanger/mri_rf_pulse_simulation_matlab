classdef sinc_verse < mri_rf_pulse_sim.rf_pulse.sinc
    % Steven Conolly, Dwight Nishimura, Albert Macovski, Gary Glover,
    % Variable-rate selective excitation, Journal of Magnetic Resonance
    % (1969), Volume 78, Issue 3, 1988, Pages 440-458, ISSN 0022-2364,
    % https://doi.org/10.1016/0022-2364(88)90131-X

    properties (GetAccess = public, SetAccess = public)
    end % props

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

            dt = diff(self.time);
            ak = rand(1,self.n_points.get());

            tv = [self.time(1)  (self.time(1) + cumsum(dt./ak(1:self.n_points.get()-1)))];

            bv = ak .* self.B1;
            gv = ak .* self.GZ;

            self.time = tv;
            self.B1 = bv;
            self.GZ = gv;
        end % fcn

    end % meths

end % class
