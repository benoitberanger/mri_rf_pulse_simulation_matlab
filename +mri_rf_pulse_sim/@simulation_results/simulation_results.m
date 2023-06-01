classdef simulation_results < mri_rf_pulse_sim.base_class

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)
        M (:,:,:,:) double

        fig matlab.ui.Figure

        axes_Mxyz matlab.graphics.axis.Axes
        line_Mx matlab.graphics.chart.primitive.Line
        line_My matlab.graphics.chart.primitive.Line
        line_Mz matlab.graphics.chart.primitive.Line

        axes_SliceProfile matlab.graphics.axis.Axes
        line_Mpara matlab.graphics.chart.primitive.Line
        line_Mperp matlab.graphics.chart.primitive.Line

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

            handles.axes_Mxyz = axes(handles.uipanel_Mxyz,...
                'OuterPosition',[0 0 1 1]);
            self.axes_Mxyz = handles.axes_Mxyz;
            hold(handles.axes_Mxyz, 'on');
            self.line_Mx = plot(handles.axes_Mxyz, 0, NaN, 'Color',[230 030 030]/255, 'LineStyle','-', 'LineWidth',1, 'DisplayName', 'Mx');
            self.line_My = plot(handles.axes_Mxyz, 0, NaN, 'Color',[030 170 230]/255, 'LineStyle','-', 'LineWidth',1, 'DisplayName', 'My');
            self.line_Mz = plot(handles.axes_Mxyz, 0, NaN, 'Color',[030 230 030]/255, 'LineStyle','-', 'LineWidth',2, 'DisplayName', 'Mz');
            xlabel(handles.axes_Mxyz, 'time (ms)');
            ylabel(handles.axes_Mxyz, 'Mxyz');
            legend(handles.axes_Mxyz)

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
            self.line_Mperp = plot(handles.axes_SliceProfile, 0, NaN, 'Color',[230 030 210]/255, 'LineStyle','-', 'LineWidth',2, 'DisplayName', 'M\perp');
            self.line_Mpara = plot(handles.axes_SliceProfile, 0, NaN, 'Color',[030 230 030]/255, 'LineStyle','-', 'LineWidth',1, 'DisplayName', 'M\mid\mid');
            xlabel(handles.axes_SliceProfile, 'dZ [mm]');
            ylabel(handles.axes_SliceProfile, 'final Mxyz');
            legend(handles.axes_SliceProfile)

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
            notify(self.app,'cleanup')
        end

    end

end % class
