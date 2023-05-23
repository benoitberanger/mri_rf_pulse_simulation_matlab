classdef app < handle

    properties (GetAccess = public,  SetAccess = protected)

        pulse_definition      mri_rf_pulse_sim.pulse_definition
        simulation_parameters mri_rf_pulse_sim.simulation_parameters
        simulation_results    mri_rf_pulse_sim.simulation_results

    end % props

    methods (Access = public)

        % contructor
        function self = app(varargin)
            if ~nargin
                self.open_gui();
            end
        end % fcn

        function simulate(self)
            self.simulation_results.M = mri_rf_pulse_sim.solve_bloch(...
                self.pulse_definition.rf_pulse.time,...
                self.pulse_definition.rf_pulse.amplitude_modulation,...
                self.pulse_definition.rf_pulse.frequency_modulation,...
                self.pulse_definition.rf_pulse.gradient_modulation,...
                self.simulation_parameters.dZ,...
                self.simulation_parameters.dB0,...
                self.pulse_definition.rf_pulse.gamma,...
                self.pulse_definition.rf_pulse.B0);
        end % fcn

        function plot(self)
            handles = guidata(self.simulation_results.fig);
            middle_dZ_idx  = round(self.simulation_parameters.dZ__N /2);
            middle_dB0_idx = round(self.simulation_parameters.dB0__N/2);
            set(handles.axes_Mxyz.Children(1),...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(1,:,middle_dZ_idx,middle_dB0_idx));
            set(handles.axes_Mxyz.Children(2),...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(2,:,middle_dZ_idx,middle_dB0_idx));
            set(handles.axes_Mxyz.Children(3),...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(3,:,middle_dZ_idx,middle_dB0_idx));
        end % fcn

    end % meths

    methods (Access = protected)

        function open_gui(self)
            self.pulse_definition = mri_rf_pulse_sim.pulse_definition('open_gui');
            self.pulse_definition.app = self;

            self.simulation_parameters = mri_rf_pulse_sim.simulation_parameters('open_gui');
            self.simulation_parameters.app = self;

            self.simulation_results = mri_rf_pulse_sim.simulation_results('open_gui');
            self.simulation_results.app = self;
        end % fcn

    end % meths

end % class
