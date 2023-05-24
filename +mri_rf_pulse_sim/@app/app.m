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
                drawnow();
                self.simplot();
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
                self.pulse_definition.rf_pulse.gamma);
        end % fcn

        function plot(self)

            % get stuff
            handles = guidata(self.simulation_results.fig);
            middle_dZ_idx  = round(self.simulation_parameters.dZ__N /2);
            middle_dB0_idx = round(self.simulation_parameters.dB0__N/2);

            % slider dZ
            handles.edit_dZ.String = num2str( self.simulation_parameters.dZ(middle_dZ_idx) * 1e3 );
            if self.simulation_parameters.dZ__N > 1
                handles.slider_dZ.Visible = true;
                d = mean(diff(self.simulation_parameters.dZ));
                handles.slider_dZ.SliderStep = [d d*10];
                handles.slider_dZ.Min = self.simulation_parameters.dZ__min;
                handles.slider_dZ.Max = self.simulation_parameters.dZ__max;
                handles.slider_dZ.Value = self.simulation_parameters.dZ(middle_dZ_idx);
            else
                handles.slider_dZ.Visible = false;
            end

            % slider dB0
            handles.edit_dB0.String = num2str( self.simulation_parameters.dB0(middle_dB0_idx) );
            if self.simulation_parameters.dB0__N > 1
                handles.slider_dB0.Visible = true;
                d = mean(diff(self.simulation_parameters.dB0));
                handles.slider_dB0.SliderStep = [d d*10];
                handles.slider_dB0.Min = self.simulation_parameters.dB0__min;
                handles.slider_dB0.Max = self.simulation_parameters.dB0__max;
                handles.slider_dB0.Value = self.simulation_parameters.dB0(middle_dB0_idx);
            else
                handles.slider_dB0.Visible = false;
            end

            % plot Mxyz
            set(handles.axes_Mxyz.Children(3),...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(1,:,middle_dZ_idx,middle_dB0_idx));
            set(handles.axes_Mxyz.Children(2),...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(2,:,middle_dZ_idx,middle_dB0_idx));
            set(handles.axes_Mxyz.Children(1),...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(3,:,middle_dZ_idx,middle_dB0_idx));

            % plot slice profile
            set(handles.axes_SliceProfile.Children(2),...
                'XData', self.simulation_parameters.dZ * 1e3,...
                'YData', sqrt(self.simulation_results.M(1,end,:,middle_dB0_idx).^2+self.simulation_results.M(2,end,:,middle_dB0_idx).^2));
            set(handles.axes_SliceProfile.Children(1),...
                'XData', self.simulation_parameters.dZ * 1e3,...
                'YData', self.simulation_results.M(3,end,:,middle_dB0_idx));

        end % fcn

        function simplot(self)
            self.simulate();
            self.plot();
        end % fcn

    end % meths

    methods (Access = protected)

        function open_gui(self)
            self.pulse_definition = mri_rf_pulse_sim.pulse_definition('open_gui');
            self.pulse_definition.app = self;
            self.pulse_definition.rf_pulse.app = self;

            self.simulation_parameters = mri_rf_pulse_sim.simulation_parameters('open_gui');
            self.simulation_parameters.app = self;

            self.simulation_results = mri_rf_pulse_sim.simulation_results('open_gui');
            self.simulation_results.app = self;
        end % fcn

    end % meths

end % class
