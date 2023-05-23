classdef app < handle

    properties (GetAccess = public,  SetAccess = protected)

        pulse_definition      mri_rf_pulse_sim.pulse_definition
        simulation_parameters mri_rf_pulse_sim.simulation_parameters
        simres   struct

    end % props

    methods (Access = public)

        % contructor
        function self = app(varargin)

            if ~nargin
                self.open_gui();
            end

        end % fcn

    end % meths

    methods (Access = protected)

        function open_gui(self)
            self.pulse_definition = mri_rf_pulse_sim.pulse_definition('open_gui');
            self.pulse_definition.app = self;

            self.simulation_parameters = mri_rf_pulse_sim.simulation_parameters('open_gui');
            self.simulation_parameters.app = self;
        end % fcn

    end % meths

end % class
