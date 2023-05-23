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

            handles.uipanel_Mxyz = uipanel(figHandle,...
                'Title','Mxyz(t)',...
                'Units','Normalized',...
                'Position',[0 0.5 1 0.5],...
                'BackgroundColor',figureBGcolor);

            handles.axes_Mxyz = axes(handles.uipanel_Mxyz);
            plot(handles.axes_Mxyz, 0, [0;0;0]) % need to 'plot' something, to set other parameters
            handles.axes_Mxyz.XLabel.String = 'time (ms)';
            handles.axes_Mxyz.YLabel.String = 'Mxyz';
            legend(handles.axes_Mxyz, {'Mx', 'Mz', 'Mz'})

            handles.uipanel_SliceProfile = uipanel(figHandle,...
                'Title','SliceProfile(dZ)',...
                'Units','Normalized',...
                'Position',[0 0 1 0.5],...
                'BackgroundColor',figureBGcolor);

            handles.axes_SliceProfile = axes(handles.uipanel_SliceProfile);
            plot(handles.axes_SliceProfile, 0, [0;0;0])
            handles.axes_SliceProfile.XLabel.String = 'dZ (mm)';
            handles.axes_SliceProfile.YLabel.String = 'final Mxyz';
            legend(handles.axes_SliceProfile, {'final Mx', 'final My', 'final Mz'})

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
