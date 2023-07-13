classdef (Abstract) duration_based < mri_rf_pulse_sim.backend.rf_pulse.abstract

    properties (GetAccess = public, SetAccess = public)
        duration mri_rf_pulse_sim.ui_prop.scalar                           % [s] pulse duration
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        tbwp (1,1) double                                                  % []    time-bandwidth product
    end % props

    methods % no attribute for dependent properies
        function value = get.tbwp(self)
            % bandwidth must depends in the pulse itself: its GET must be defined in the subclass
            value = self.duration * self.bandwidth;
        end % fcn
    end % meths

    methods (Access = public)

        % constructor
        function self = duration_based(varargin)
            self.duration = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='duration', value=  5 * 1e-3, unit='ms', scale=1e3);
        end

        function init_base_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar( ...
                container, ...
                [self.n_points, self.duration] ...
                );
        end % fcn
        
    end % meths

end % class
