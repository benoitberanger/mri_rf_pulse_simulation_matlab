classdef app < handle
    % This is the application class. It handles everything. Most of the user actions should be done using this class.
    %
    % START THE APP
    %         mri_rf_pulse_sim.app      % for only GUI operations
    %   app = mri_rf_pulse_sim.app()    % to keep a handle to the application, for later Scripting or CommandWindow operations
    %


    %% Public

    properties (GetAccess = public,  SetAccess = protected)
        pulse_definition      mri_rf_pulse_sim.backend.gui.pulse_definition
        simulation_parameters mri_rf_pulse_sim.backend.gui.simulation_parameters
        simulation_results    mri_rf_pulse_sim.backend.gui.simulation_results
        window_definition     mri_rf_pulse_sim.backend.gui.window_definition

        bloch_solver          mri_rf_pulse_sim.bloch_solver

        fig                   matlab.ui.Figure % for the "one figure" configuration
    end % props

    methods (Access = public)

        %------------------------------------------------------------------
        % basic methods
        %------------------------------------------------------------------

        % contructor
        function self = app(action)
            arguments
                action (1,:) {mustBeTextScalar} = "opengui"
            end

            addpath(fileparts(mri_rf_pulse_sim.get_package_dir())); % recommanded for a clean app close

            self.bloch_solver = mri_rf_pulse_sim.bloch_solver();

            fprintf('[app]: opengui() ... ')
            tic
            switch lower(action)
                case "opengui"
                    self.opengui();
                case "opengui_onefig"
                    self.opengui("onefig");
                otherwise
                    error('unkwnown action : %s', action)
            end
            fprintf('done in %.3gs \n', toc)
            drawnow();
            self.simplot();

        end % fcn

        function simplot(self)
            self.simulate();
            self.plot();
        end % fcn

        %------------------------------------------------------------------
        % get/set methods
        %------------------------------------------------------------------

        % rf pulse
        function value = getPulse(self)
            value = self.pulse_definition.rf_pulse;
        end
        function pulse_obj = setPulse(self,value)
            pulse_obj = self.pulse_definition.set_rf_pulse(value);
        end

        % auto simplot
        function value = getAutoSimPlot(self)
            value = self.simulation_parameters.auto_simplot.get();
        end
        function setAutoSimPlotTrue(self)
            self.simulation_parameters.auto_simplot.setTrue();
        end
        function setAutoSimPlotFalse(self)
            self.simulation_parameters.auto_simplot.setFalse();
        end

        % auto disp pulse
        function value = getAutoDispPulse(self)
            value = self.simulation_parameters.auto_disp_pulse.get();
        end
        function setAutoDispPulseTrue(self)
            self.simulation_parameters.auto_disp_pulse.setTrue();
        end
        function setAutoDispPulseFalse(self)
            self.simulation_parameters.auto_disp_pulse.setFalse();
        end


        %------------------------------------------------------------------
        % other methods
        %------------------------------------------------------------------

        function simulate(self)
            fprintf('[app]: simulate() ... ')
            tic;
            self.bloch_solver.setPulse(self.getPulse());
            self.bloch_solver.solve();
            fprintf('done in %.3gs \n', toc)
        end % fcn

        function plot(self)

            % get stuff
            dZ  = self.simulation_parameters.dZ ;
            dB0 = self.simulation_parameters.dB0;
            time = self.pulse_definition.rf_pulse.time * 1e3;
            bloch = self.bloch_solver;
            pulse = self.getPulse();

            % plot Mxyz
            set(self.simulation_results.line_M_up  ,'XData', [time(1) time(end)], 'YData', [+1 +1]);
            set(self.simulation_results.line_M_mid ,'XData', [time(1) time(end)], 'YData', [ 0  0]);
            set(self.simulation_results.line_M_down,'XData', [time(1) time(end)], 'YData', [-1 -1]);
            set(self.simulation_results.line_M_x,   'XData',                time, 'YData', bloch.getTimeseriesX   (dZ.selected_value, dB0.selected_value));
            set(self.simulation_results.line_M_y,   'XData',                time, 'YData', bloch.getTimeseriesY   (dZ.selected_value, dB0.selected_value));
            set(self.simulation_results.line_M_para,'XData',                time, 'YData', bloch.getTimeseriesPara(dZ.selected_value, dB0.selected_value));
            set(self.simulation_results.line_M_perp,'XData',                time, 'YData', bloch.getTimeseriesPerp(dZ.selected_value, dB0.selected_value));

            % plot line 3D
            set(self.simulation_results.line3_Mxyz,...
                'XData', bloch.getTimeseriesX(dZ.selected_value, dB0.selected_value),...
                'YData', bloch.getTimeseriesY(dZ.selected_value, dB0.selected_value),...
                'ZData', bloch.getTimeseriesZ(dZ.selected_value, dB0.selected_value));
            set(self.simulation_results.q3_Mxyz_end,...
                'XData',0, 'YData',0, 'ZData',0, ...
                'UData',self.simulation_results.line3_Mxyz.XData(end),...
                'VData',self.simulation_results.line3_Mxyz.YData(end),...
                'WData',self.simulation_results.line3_Mxyz.ZData(end));

            % plot slice profile
            dz = dZ.vect * dZ.scale;
            set(self.simulation_results.line_S_up   ,'XData', [dz(1) dz(end)], 'YData', [+1 +1]);
            set(self.simulation_results.line_S_mid  ,'XData', [dz(1) dz(end)], 'YData', [ 0  0]);
            set(self.simulation_results.line_S_down ,'XData', [dz(1) dz(end)], 'YData', [-1 -1]);
            set(self.simulation_results.line_S_Mx   ,'XData',              dz, 'YData', bloch.getSliceProfileX   (dB0.selected_value));
            set(self.simulation_results.line_S_My   ,'XData',              dz, 'YData', bloch.getSliceProfileY   (dB0.selected_value));
            set(self.simulation_results.line_S_Mpara,'XData',              dz, 'YData', bloch.getSliceProfilePara(dB0.selected_value));
            set(self.simulation_results.line_S_Mperp,'XData',              dz, 'YData', bloch.getSliceProfilePerp(dB0.selected_value));
            set(self.simulation_results.line_S_vert ,'XData', [dZ.selected_value dZ.selected_value].*dZ.scale);
            set(self.simulation_results.line_S_stL  ,'XData', -[pulse.slice_thickness.value pulse.slice_thickness.value]/2 * pulse.slice_thickness.scale);
            set(self.simulation_results.line_S_stR  ,'XData', +[pulse.slice_thickness.value pulse.slice_thickness.value]/2 * pulse.slice_thickness.scale);

            % plot chemical shift
            db0 = dB0.vect * dB0.scale;
            set(self.simulation_results.line_C_up   ,'XData', [db0(1) db0(end)], 'YData', [+1 +1]);
            set(self.simulation_results.line_C_mid  ,'XData', [db0(1) db0(end)], 'YData', [ 0  0]);
            set(self.simulation_results.line_C_down ,'XData', [db0(1) db0(end)], 'YData', [-1 -1]);
            set(self.simulation_results.line_C_Mx   ,'XData',               db0, 'YData', bloch.getChemicalShiftX   (dZ.selected_value));
            set(self.simulation_results.line_C_My   ,'XData',               db0, 'YData', bloch.getChemicalShiftY   (dZ.selected_value));
            set(self.simulation_results.line_C_Mpara,'XData',               db0, 'YData', bloch.getChemicalShiftPara(dZ.selected_value));
            set(self.simulation_results.line_C_Mperp,'XData',               db0, 'YData', bloch.getChemicalShiftPerp(dZ.selected_value));
            set(self.simulation_results.line_C_vert ,'XData', [dB0.selected_value dB0.selected_value].*dB0.scale);

        end % fcn

        function open_window_gui(self)
            self.window_definition = mri_rf_pulse_sim.backend.gui.window_definition('open_gui', self);
            notify(self, 'update_window');
        end % fcn

    end % meths


    %% Private

    events
        update_pulse
        update_setup
        update_select

        cleanup

        update_window
    end
    properties (GetAccess = public,  SetAccess = protected, Hidden)
        listener__update_pulse  event.listener
        listener__update_setup  event.listener
        listener__update_select event.listener

        listener__cleanup       event.listener

        listener__update_window event.listener
    end % props

    methods (Access = protected)

        function opengui(self, action)
            arguments
                self
                action (1,:) {mustBeTextScalar} = ""
            end

            switch action

                case "onefig"

                    self.fig = figure( ...
                        'MenuBar'         , 'none'                   , ...
                        'Toolbar'         , 'none'                   , ...
                        'Name'            , 'MRI RF pulse simulation', ...
                        'NumberTitle'     , 'off'                    , ...
                        'Units'           , 'normalized'             , ...
                        'Position'        , [0.1 0.1 0.8 0.8]        , ...
                        'CloseRequestFcn' , @self.callback_cleanup   );

                    figureBGcolor = [0.9 0.9 0.9]; set(self.fig,'Color',figureBGcolor);
                    buttonBGcolor = figureBGcolor - 0.1;
                    editBGcolor   = [1.0 1.0 1.0];

                    % Create GUI handles : pointers to access the graphic objects
                    handles               = guihandles(self.fig);
                    handles.fig           = self.fig;
                    handles.figureBGcolor = figureBGcolor;
                    handles.buttonBGcolor = buttonBGcolor;
                    handles.editBGcolor   = editBGcolor  ;

                    guidata(self.fig,handles)

                    action = "_" + action;
            end

            self.pulse_definition      = mri_rf_pulse_sim.backend.gui.pulse_definition     (app=self, action="opengui"+action);
            self.simulation_parameters = mri_rf_pulse_sim.backend.gui.simulation_parameters(app=self, action="opengui"+action);
            self.simulation_results    = mri_rf_pulse_sim.backend.gui.simulation_results   (app=self, action="opengui"+action);

            self.bloch_solver.setSpatialPosition(self.simulation_parameters.dZ );
            self.bloch_solver.setDeltaB0        (self.simulation_parameters.dB0);
            self.bloch_solver.setB0             (self.simulation_parameters.B0 );
            self.bloch_solver.setT1             (self.simulation_parameters.T1 );
            self.bloch_solver.setT2             (self.simulation_parameters.T2 );
            self.bloch_solver.setM0             (self.simulation_parameters.M0 );

            self.listener__update_pulse  = addlistener(self, 'update_pulse' , @self.callback__update_pulse );
            self.listener__update_setup  = addlistener(self, 'update_setup' , @self.callback__update_setup );
            self.listener__update_select = addlistener(self, 'update_select', @self.callback__update_select);

            self.listener__update_window = addlistener(self, 'update_window', @self.callback__update_window);

            self.listener__cleanup = addlistener(self, 'cleanup', @self.callback_cleanup);
        end % fcn

        function callback__update_pulse(self, ~, ~)
            if self.getAutoDispPulse()
                disp(self.pulse_definition.rf_pulse)
            end
            if self.getAutoSimPlot()
                self.simplot();
            end
        end % fcn

        function callback__update_setup(self, ~, ~)
            if self.simulation_parameters.auto_simplot.get()
                self.simplot();
            end
        end % fcn

        function callback__update_select(self, ~, ~)
            self.plot();
        end % fcn

        function callback__update_window(self, ~, ~)
            if ishandle(self.window_definition.fig) % fig is opened

                % fetch
                handles = guidata(self.window_definition.fig);
                rf_pulse = self.pulse_definition.rf_pulse;
                window = self.window_definition.window;

                % link
                rf_pulse.window = window;
                window.rf_pulse = rf_pulse;

                % generate & plot
                rf_pulse.window.plot(handles.uipanel_plot);
                self.pulse_definition.callback_update();

            else % deleted window

                % fetch
                rf_pulse = self.pulse_definition.rf_pulse;

                % link
                delete(rf_pulse.window);

                % generate & plot
                self.pulse_definition.callback_update();
            end
        end % fcn

    end % meths

    methods(Access = { ...
            ?mri_rf_pulse_sim.pulse_definition, ...
            ?mri_rf_pulse_sim.simulation_parameters, ...
            ?mri_rf_pulse_sim.simulation_results, ...
            ?mri_rf_pulse_sim.window_definition ...
            })

        function callback_cleanup(self, ~, ~)
            fprintf('[app]: cleanup() ... ')
            tic
            try delete(self.                      fig); catch, end
            try delete(self.window_definition    .fig); catch, end
            try delete(self.pulse_definition     .fig); catch, end
            try delete(self.simulation_parameters.fig); catch, end
            try delete(self.simulation_results   .fig); catch, end
            fprintf('done in %.3gs \n', toc)
        end

    end % meths

end % class
