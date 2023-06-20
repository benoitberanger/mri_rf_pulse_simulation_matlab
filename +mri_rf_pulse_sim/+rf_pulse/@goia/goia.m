classdef goia < mri_rf_pulse_sim.rf_pulse.foci

    properties (GetAccess = public, SetAccess = public)

        n mri_rf_pulse_sim.ui_prop.scalar
        m mri_rf_pulse_sim.ui_prop.scalar

    end % props

    methods (Access = public)

        function self = goia()
            self@mri_rf_pulse_sim.rf_pulse.foci(); % call HS constructor
            self.n = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n', value=1);
            self.m = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='m', value=1);
            self.generate_goia();
        end % fcn

        function generate(self)
            self.generate_goia();
        end % fcn

        function generate_goia(self)

        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.A0, self.beta, self.mu, self.gz self.n self.m]...
                );
        end % fcn

    end % meths

end % class
