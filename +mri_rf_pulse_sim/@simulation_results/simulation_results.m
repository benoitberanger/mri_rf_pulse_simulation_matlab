classdef simulation_results < handle

    properties(GetAccess = public, SetAccess = {?mri_rf_pulse_sim.app})
        M (:,:,:,:) double
    end % props

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)
        app mri_rf_pulse_sim.app
        fig matlab.ui.Figure
    end % props

    methods (Access = public)

        function self = simulation_results(varargin)
            if nargin < 1
                return
            end

            action = varargin{1};
            switch action
                case 'open_gui'
                    self.open_gui();
                otherwise
                    error('unknown action')
            end
        end % fcn

        function varargout = open_gui(self)

            % Create a figure
            figHandle = figure( ...
                'MenuBar'         , 'none'                   , ...
                'Toolbar'         , 'none'                   , ...
                'Name'            , 'Simulation results'     , ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'Pixels'                 , ...
                'Position'        , [800, 50, 600, 750]      , ...
                'Tag'             , 'mri_rf_pulse_sim.app.simulation_results');

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
            % Sliders

            handles.uipanel_Selection = uipanel(figHandle,...
                'Title','Selection',...
                'Units','Normalized',...
                'Position',[0 0.8 1 0.2],...
                'BackgroundColor',figureBGcolor);

            handles.text_dZ = uicontrol(handles.uipanel_Selection,...
                'Style','text',...
                'Units','normalized',...
                'Position',[0 0.8 0.2 0.2],...
                'BackgroundColor',figureBGcolor,...
                'String','dZ [mm] = ');
            handles.edit_dZ = uicontrol(handles.uipanel_Selection,...
                'Style','edit',...
                'String','',...
                'Units','normalized',...
                'Position',[0.2 0.8 0.2 0.2]);
            handles.slider_dZ = uicontrol(handles.uipanel_Selection,...
                'Style','slider',...
                'Units','normalized',...
                'Position',[0.4 0.8 0.6 0.2]);

            handles.text_dB0 = uicontrol(handles.uipanel_Selection,...
                'Style','text',...
                'Units','normalized',...
                'Position',[0 0.6 0.2 0.2],...
                'BackgroundColor',figureBGcolor,...
                'String','dB0 [ppm] = ');
            handles.edit_dB0 = uicontrol(handles.uipanel_Selection,...
                'Style','edit',...
                'String','',...
                'Units','normalized',...
                'Position',[0.2 0.6 0.2 0.2]);
            handles.slider_dB0 = uicontrol(handles.uipanel_Selection,...
                'Style','slider',...
                'Units','normalized',...
                'Position',[0.4 0.6 0.6 0.2]);

            %--------------------------------------------------------------
            % Mxyz

            handles.uipanel_Mxyz = uipanel(figHandle,...
                'Title','Mxyz(t)',...
                'Units','Normalized',...
                'Position',[0 0.4 1 0.4],...
                'BackgroundColor',figureBGcolor);

            handles.axes_Mxyz = axes(handles.uipanel_Mxyz,...
                'OuterPosition',[0 0 1 1]);
            plot(handles.axes_Mxyz, 0, [0;0;0]) % need to 'plot' something, to set other parameters
            handles.axes_Mxyz.Children(3).Color = [230 030 030]/255;
            handles.axes_Mxyz.Children(2).Color = [030 170 230]/255;
            handles.axes_Mxyz.Children(1).Color = [030 230 030]/255;
            handles.axes_Mxyz.XLabel.String = 'time (ms)';
            handles.axes_Mxyz.YLabel.String = 'Mxyz';
            legend(handles.axes_Mxyz, {'Mx', 'My', 'Mz'})

            %--------------------------------------------------------------
            % SliceProfile
            handles.uipanel_SliceProfile = uipanel(figHandle,...
                'Title','SliceProfile(dZ)',...
                'Units','Normalized',...
                'Position',[0 0 1 0.4],...
                'BackgroundColor',figureBGcolor);

            handles.axes_SliceProfile = axes(handles.uipanel_SliceProfile);
            plot(handles.axes_SliceProfile, 0, [0;0])
            handles.axes_SliceProfile.Children(2).Color = [230 030 210]/255;
            handles.axes_SliceProfile.Children(1).Color = [030 230 030]/255;
            handles.axes_SliceProfile.XLabel.String = 'dZ [mm]';
            handles.axes_SliceProfile.YLabel.String = 'final Mxyz';
            legend(handles.axes_SliceProfile, {'M\mid\mid', 'M\perp'})

            % IMPORTANT
            guidata(figHandle,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            self.fig = figHandle;

            if nargout > 0
                varargout{1} = self;
            end

            % initialize with default values

        end % fcn

    end % meths

    methods(Access = protected)
    end % meths

    methods (Static, Access = protected)
    end % meths

end % class
