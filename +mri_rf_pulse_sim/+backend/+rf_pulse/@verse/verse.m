classdef (Abstract) verse < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Steven Conolly, Dwight Nishimura, Albert Macovski, Gary Glover,
    % Variable-rate selective excitation, Journal of Magnetic Resonance
    % (1969), Volume 78, Issue 3, 1988, Pages 440-458, ISSN 0022-2364,
    % https://doi.org/10.1016/0022-2364(88)90131-X

    properties (GetAccess = public, SetAccess = public)
    end % props

    methods(Access = public)

        function verse_rand(self)
            npts = self.n_points.get();
            dt = diff(self.time);

            ak = rand(1,npts);
            tv = [self.time(1)  (self.time(1) + cumsum(dt./ak(1:npts-1)))];
            bv = ak .* self.B1;
            gv = ak .* self.GZ;

            self.time = tv;
            self.B1   = bv;
            self.GZ   = gv;
        end % fcn

        function init_verse_gui(self, container)
        end % fcn

    end % meths

end % class
