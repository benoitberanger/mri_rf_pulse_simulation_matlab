classdef simulation_results < mri_rf_pulse_sim.base_class

    properties(GetAccess = public, SetAccess = {?mri_rf_pulse_sim.app})
        M (:,:,:,:) double
    end % props

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)
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
                'Position'        , [800, 50, 600, 750]      );

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

            % initialize with default values

        end % fcn

    end % meths

end % class
