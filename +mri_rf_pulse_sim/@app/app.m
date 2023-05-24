classdef app < handle

    properties (GetAccess = public,  SetAccess = protected)
        pulse_definition      mri_rf_pulse_sim.pulse_definition
        simulation_parameters mri_rf_pulse_sim.simulation_parameters
        simulation_results    mri_rf_pulse_sim.simulation_results

        listener__update_pulse  event.listener
        listener__update_setup  event.listener
        listener__update_select event.listener
    end % props

    events
        update_pulse
        update_setup
        update_select
    end

    methods (Access = public)

        % contructor
        function self = app(varargin)
            if ~nargin
                fprintf('[app]: open_gui() ... ')
                tic;
                self.open_gui();
                fprintf('done in %.3gs \n', toc)

                drawnow();

                self.simplot();
            end
        end % fcn

        function simulate(self)
            fprintf('[app]: simulate() ... ')
            tic;
            self.simulation_results.M = mri_rf_pulse_sim.solve_bloch(...
                self.pulse_definition.rf_pulse.time,...
                self.pulse_definition.rf_pulse.amplitude_modulation,...
                self.pulse_definition.rf_pulse.frequency_modulation,...
                self.pulse_definition.rf_pulse.gradient_modulation,...
                self.simulation_parameters.dZ.vect,...
                self.simulation_parameters.dB0.vect,...
                self.pulse_definition.rf_pulse.gamma);
            fprintf('done in %.3gs \n', toc)
        end % fcn

        function plot(self)

            % get stuff
            handles = guidata(self.simulation_results.fig);
            dZ  = self.simulation_parameters.dZ ;
            dB0 = self.simulation_parameters.dB0;

            idx_dZ  = find(dZ .vect == dZ .select);
            idx_dB0 = find(dB0.vect == dB0.select);

            % plot Mxyz
            set(handles.axes_Mxyz.Children(3),...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(1,:,idx_dZ,idx_dB0));
            set(handles.axes_Mxyz.Children(2),...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(2,:,idx_dZ,idx_dB0));
            set(handles.axes_Mxyz.Children(1),...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(3,:,idx_dZ,idx_dB0));

            % plot slice profile
            set(handles.axes_SliceProfile.Children(2),...
                'XData', dZ.vect * dZ.scale,...
                'YData', sqrt(self.simulation_results.M(1,end,:,idx_dB0).^2+self.simulation_results.M(2,end,:,idx_dB0).^2));
            set(handles.axes_SliceProfile.Children(1),...
                'XData', dZ.vect * dZ.scale,...
                'YData', self.simulation_results.M(3,end,:,idx_dB0));

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
            self.listener__update_pulse = addlistener(self, 'update_pulse' , @self.callback__update_pulse);

            self.simulation_parameters = mri_rf_pulse_sim.simulation_parameters('open_gui');
            self.simulation_parameters.app = self;

            self.simulation_results = mri_rf_pulse_sim.simulation_results('open_gui');
            self.simulation_results.app = self;
            H_sr = guidata(self.simulation_results.fig);
            self.simulation_parameters.dZ .add_uicontrol_select(H_sr.uipanel_dZ) ;
            self.simulation_parameters.dB0.add_uicontrol_select(H_sr.uipanel_dB0);

            self.listener__update_setup  = addlistener(self, 'update_setup' , @self.callback__update_setup );
            self.listener__update_select = addlistener(self, 'update_select', @self.callback__update_select);
            self.simulation_parameters.dZ .app = self;
            self.simulation_parameters.dB0.app = self;
        end % fcn

        function callback__update_pulse(self, ~, ~)
            if self.simulation_parameters.auto_simplot
                self.simplot();
            end
        end

        function callback__update_setup(self, ~, ~)
            if self.simulation_parameters.auto_simplot
                self.simplot();
            end
        end

        function callback__update_select(self, ~, ~)
            if self.simulation_parameters.auto_simplot
                self.plot();
            end
        end

    end % meths

end % class
