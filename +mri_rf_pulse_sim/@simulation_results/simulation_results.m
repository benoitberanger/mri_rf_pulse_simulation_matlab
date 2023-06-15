classdef simulation_results < mri_rf_pulse_sim.base_class

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)
        M (:,:,:,:) double

        fig matlab.ui.Figure

        axes_Mxyz  matlab.graphics.axis.Axes
        line_Mx    matlab.graphics.chart.primitive.Line
        line_My    matlab.graphics.chart.primitive.Line
        line_Mz    matlab.graphics.chart.primitive.Line
        line_Mup   matlab.graphics.chart.primitive.Line
        line_Mmid  matlab.graphics.chart.primitive.Line
        line_Mdown matlab.graphics.chart.primitive.Line

        axes_Sphere    matlab.graphics.axis.Axes
        surface_Sphere matlab.graphics.chart.primitive.Surface
        line3_Mxyz     matlab.graphics.chart.primitive.Line
        q3_Mxyz_end    matlab.graphics.chart.primitive.Quiver

        axes_SliceProfile matlab.graphics.axis.Axes
        line_Mpara        matlab.graphics.chart.primitive.Line
        line_Mperp        matlab.graphics.chart.primitive.Line
        line_Sup          matlab.graphics.chart.primitive.Line
        line_Smid         matlab.graphics.chart.primitive.Line
        line_Sdown        matlab.graphics.chart.primitive.Line
    end % props

    methods (Access = public)

        function self = simulation_results(varargin)
            if nargin < 1
                return
            end

            action = varargin{1};
            switch action
                case 'open_gui'
                    if nargin > 1
                        self.app = varargin{2};
                    end
                    self.open_gui();
                otherwise
                    error('unknown action')
            end
        end % fcn

        function open_gui(self)

            % Create a figure
            figHandle = figure( ...
                'MenuBar'         , 'none'                   , ...
                'Toolbar'         , 'none'                   , ...
                'Name'            , 'Simulation results'     , ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'Pixels'                 , ...
                'Position'        , [800, 50, 600, 750]      , ...
                'CloseRequestFcn' , @self.callback_cleanup   );

            figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
            buttonBGcolor = figureBGcolor - 0.1;
            editBGcolor   = [1.0 1.0 1.0];

            % Create GUI handles : pointers to access the graphic objects
            handles               = guihandles(figHandle);
            handles.fig           = figHandle;
            handles.figureBGcolor = figureBGcolor;
            handles.buttonBGcolor = buttonBGcolor;
            handles.editBGcolor   = editBGcolor  ;

            %--------------------------------------------------------------
            % Range selection

            handles.uipanel_dZ = uipanel(figHandle,...
                'Title','Selection',...
                'Units','Normalized',...
                'Position',[0 0.9 1 0.1],...
                'BackgroundColor',figureBGcolor);

            handles.uipanel_dB0 = uipanel(figHandle,...
                'Title','Selection',...
                'Units','Normalized',...
                'Position',[0 0.8 1 0.1],...
                'BackgroundColor',figureBGcolor);

            self.app.simulation_parameters.dZ .add_uicontrol_select(handles.uipanel_dZ )
            self.app.simulation_parameters.dB0.add_uicontrol_select(handles.uipanel_dB0)
            self.app.simulation_parameters.dZ .app = self.app;
            self.app.simulation_parameters.dB0.app = self.app;

            %--------------------------------------------------------------
            % Mxyz

            handles.uipanel_Mxyz = uipanel(figHandle,...
                'Title','Mxyz(t)',...
                'Units','Normalized',...
                'Position',[0 0.4 1 0.4],...
                'BackgroundColor',figureBGcolor);

            time = self.app.pulse_definition.rf_pulse.time;

            handles.axes_Mxyz = axes(handles.uipanel_Mxyz,...
                'OuterPosition',[0 0 0.7 1]);
            self.axes_Mxyz = handles.axes_Mxyz;
            hold(handles.axes_Mxyz, 'on');
            self.line_Mx = plot(handles.axes_Mxyz, 0, NaN, 'Color',[230 030 030]/255, 'LineStyle','-', 'LineWidth',2);
            self.line_My = plot(handles.axes_Mxyz, 0, NaN, 'Color',[030 170 230]/255, 'LineStyle','-', 'LineWidth',2);
            self.line_Mz = plot(handles.axes_Mxyz, 0, NaN, 'Color',[030 230 030]/255, 'LineStyle','-', 'LineWidth',2);
            self.line_Mup   = plot(handles.axes_Mxyz, [time(1) time(end)], [+1 +1], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5]);
            self.line_Mmid  = plot(handles.axes_Mxyz, [time(1) time(end)], [ 0  0], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5]);
            self.line_Mdown = plot(handles.axes_Mxyz, [time(1) time(end)], [-1 -1], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5]);
            legend(handles.axes_Mxyz, {'Mx', 'My', 'Mz'})
            axis(handles.axes_Mxyz, 'tight')
            xlabel(handles.axes_Mxyz, 'time (ms)');
            ylabel(handles.axes_Mxyz, 'Mxyz');
            ylim(handles.axes_Mxyz, [-1.1 +1.1])

            handles.axes_Sphere = axes(handles.uipanel_Mxyz,...
                'Position',[0.7 0 0.3 1]);
            self.axes_Sphere = handles.axes_Sphere;
            hold(handles.axes_Sphere, 'on')
            [X,Y,Z] = sphere(100);
            self.surface_Sphere = surf(handles.axes_Sphere, X, Y , Z, 'FaceAlpha',0.2, 'EdgeColor','none');
            colormap(self.axes_Sphere, white)
            self.line3_Mxyz = plot3(handles.axes_Sphere, 0,0,0, 'LineWidth', 2);
            self.q3_Mxyz_end = quiver3(handles.axes_Sphere,0,0,0,0,0,0,0,'Color',[000 000 000]/255,'LineWidth',2);
            axis(handles.axes_Sphere, 'off')
            rotate3d(handles.axes_Sphere, 'on')
            axis(handles.axes_Sphere, 'vis3d')
            view(handles.axes_Sphere,[1 1 1])
            quiver3(handles.axes_Sphere,0,0,0,1,0,0,0,'Color',[230 030 030]/255)
            quiver3(handles.axes_Sphere,0,0,0,0,1,0,0,'Color',[030 170 230]/255)
            quiver3(handles.axes_Sphere,0,0,0,0,0,1,0,'Color',[030 230 030]/255)

            %--------------------------------------------------------------
            % SliceProfile
            handles.uipanel_SliceProfile = uipanel(figHandle,...
                'Title','SliceProfile(dZ)',...
                'Units','Normalized',...
                'Position',[0 0 1 0.4],...
                'BackgroundColor',figureBGcolor);

            handles.axes_SliceProfile = axes(handles.uipanel_SliceProfile);
            self.axes_SliceProfile = handles.axes_SliceProfile;
            hold(handles.axes_SliceProfile, 'on')
            self.line_Mperp = plot(handles.axes_SliceProfile, 0, NaN, 'Color',[230 030 210]/255, 'LineStyle','-', 'LineWidth',2);
            self.line_Mpara = plot(handles.axes_SliceProfile, 0, NaN, 'Color',[030 230 030]/255, 'LineStyle','-', 'LineWidth',2);
            self.line_Sup   = plot(handles.axes_SliceProfile, [time(1) time(end)], [+1 +1], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5]);
            self.line_Smid  = plot(handles.axes_SliceProfile, [time(1) time(end)], [ 0  0], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5]);
            self.line_Sdown = plot(handles.axes_SliceProfile, [time(1) time(end)], [-1 -1], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5]);
            legend(handles.axes_SliceProfile, {'M\perp', 'M\mid\mid'})
            xlabel(handles.axes_SliceProfile, 'dZ [mm]');
            ylabel(handles.axes_SliceProfile, 'final Mxyz');
            legend(handles.axes_SliceProfile)
            ylim(handles.axes_SliceProfile, [-1.2 +1.2])


            % IMPORTANT
            guidata(figHandle,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            self.fig = figHandle;

            % initialize with default values

        end % fcn

    end % meths

    methods(Access = protected)

        function callback_cleanup(self,varargin)
            delete(self.fig)
            notify(self.app,'cleanup')
        end

    end

end % class
