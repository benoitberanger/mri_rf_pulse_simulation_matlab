classdef app < handle

    properties (GetAccess = public,  SetAccess = protected)
        pulse_definition      mri_rf_pulse_sim.pulse_definition
        simulation_parameters mri_rf_pulse_sim.simulation_parameters
        simulation_results    mri_rf_pulse_sim.simulation_results
    end % props

    properties (GetAccess = public,  SetAccess = protected, Hidden)
        listener__update_pulse  event.listener
        listener__update_setup  event.listener
        listener__update_select event.listener

        listener__cleanup       event.listener
    end % props

    events
        update_pulse
        update_setup
        update_select

        cleanup
    end

    methods (Access = public)

        % contructor
        function self = app(varargin)
            if ~nargin
                fprintf('[app]: open_gui() ... ')
                tic
                self.open_gui();
                fprintf('done in %.3gs \n', toc)

                self.listener__cleanup = addlistener(self, 'cleanup', @self.callback_cleanup);

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
            dZ  = self.simulation_parameters.dZ ;
            dB0 = self.simulation_parameters.dB0;

            idx_dZ  = find(dZ .vect == dZ .select);
            idx_dB0 = find(dB0.vect == dB0.select);

            % plot Mxyz
            set(self.simulation_results.line_Mx,...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(1,:,idx_dZ,idx_dB0));
            set(self.simulation_results.line_My,...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(2,:,idx_dZ,idx_dB0));
            set(self.simulation_results.line_Mz,...
                'XData', self.pulse_definition.rf_pulse.time * 1e3,...
                'YData', self.simulation_results.M(3,:,idx_dZ,idx_dB0));

            % plot line 3D
            set(self.simulation_results.line3_Mxyz,...
                'XData', self.simulation_results.M(1,:,idx_dZ,idx_dB0),...
                'YData', self.simulation_results.M(2,:,idx_dZ,idx_dB0),...
                'ZData', self.simulation_results.M(3,:,idx_dZ,idx_dB0));
            set(self.simulation_results.q3_Mxyz_end,...
                'XData',0, 'YData',0, 'ZData',0, ...
                'UData',self.simulation_results.M(1,end,idx_dZ,idx_dB0), ...
                'VData',self.simulation_results.M(2,end,idx_dZ,idx_dB0), ...
                'WData',self.simulation_results.M(3,end,idx_dZ,idx_dB0)  ...
                );
            
            % plot slice profile
            set(self.simulation_results.line_Mperp,...
                'XData', dZ.vect * dZ.scale,...
                'YData', sqrt(self.simulation_results.M(1,end,:,idx_dB0).^2+self.simulation_results.M(2,end,:,idx_dB0).^2));
            set(self.simulation_results.line_Mpara,...
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
            self.pulse_definition      = mri_rf_pulse_sim.pulse_definition     ('open_gui', self);
            self.simulation_parameters = mri_rf_pulse_sim.simulation_parameters('open_gui', self);
            self.simulation_results    = mri_rf_pulse_sim.simulation_results   ('open_gui', self);

            self.listener__update_pulse  = addlistener(self, 'update_pulse' , @self.callback__update_pulse );
            self.listener__update_setup  = addlistener(self, 'update_setup' , @self.callback__update_setup );
            self.listener__update_select = addlistener(self, 'update_select', @self.callback__update_select);
        end % fcn

        function callback__update_pulse(self, ~, ~)
            if self.simulation_parameters.auto_simplot
                self.simplot();
            end
        end % fcn

        function callback__update_setup(self, ~, ~)
            if self.simulation_parameters.auto_simplot
                self.simplot();
            end
        end % fcn

        function callback__update_select(self, ~, ~)
            if self.simulation_parameters.auto_simplot
                self.plot();
            end
        end % fcn

    end % meths

    methods(Access = {?mri_rf_pulse_sim.pulse_definition, ?mri_rf_pulse_sim.simulation_parameters, ?mri_rf_pulse_sim.simulation_results})

        function callback_cleanup(self, ~, ~)
            fprintf('[app]: cleanup() ... ')
            tic
            try delete(self.pulse_definition     .fig); catch, end
            try delete(self.simulation_parameters.fig); catch, end
            try delete(self.simulation_results   .fig); catch, end
            fprintf('done in %.3gs \n', toc)
        end

    end % meths

end % class
