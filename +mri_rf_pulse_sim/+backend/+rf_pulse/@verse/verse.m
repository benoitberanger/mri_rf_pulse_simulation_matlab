classdef (Abstract) verse < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Steven Conolly, Dwight Nishimura, Albert Macovski, Gary Glover,
    % Variable-rate selective excitation, Journal of Magnetic Resonance
    % (1969), Volume 78, Issue 3, 1988, Pages 440-458, ISSN 0022-2364,
    % https://doi.org/10.1016/0022-2364(88)90131-X

    properties (GetAccess = public, SetAccess = public)
        type  mri_rf_pulse_sim.ui_prop.list
        maxB1 mri_rf_pulse_sim.ui_prop.scalar                              % [T]     max value of magnitude(t)
        maxGZ mri_rf_pulse_sim.ui_prop.scalar                              % [T/m]   max value of  gradient(t)
        maxSZ mri_rf_pulse_sim.ui_prop.scalar                              % [T/m/s] max(dGZ/dt)
    end % props

    methods(Access = public)

        function self = verse()
            self.type  = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='type' , value= 'rand' , items= {'minimum_time', 'low_sar', 'rand'});
            self.maxB1 = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='maxB1', value= 15e-6, scale=1e6, unit='µT'     );
            self.maxGZ = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='maxGZ', value= 40e-3, scale=1e3, unit='mT/m'   );
            self.maxSZ = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='maxSZ', value=120e-3, scale=1e3, unit='mT/m/ms');
        end % fcn

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
            self.type.add_uicontrol(container, [0.00 0.00 0.40 1.00]);
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.maxB1 self.maxGZ self.maxSZ],...
                [0.40 0.00 0.60 1.00]);
        end % fcn

    end % meths

end % class
