classdef app < handle

    properties (GetAccess = public,  SetAccess = public)

        rf_pulse     mri_rf_pulse_sim.rf_pulse.base

    end % props

    properties (GetAccess = public,  SetAccess = protected)

        pulsedef struct
        simpar   struct
        simres   struct

    end % props

    methods (Access = public)

        % contructor
        function self = app(varargin)

            if ~nargin
                self.open_gui();
            end

        end % fcn

    end % meths

    methods (Access = protected)

        function open_gui(self)
            self.fig_pulsedef = self.open_gui_pulsedef();
        end % fcn

        function varargout = open_gui_pulsedef(self)

            % Create a figure
            figHandle = uifigure( ...
                'HandleVisibility', 'off',... % close all does not close the figure
                'MenuBar'         , 'none'                   , ...
                'Toolbar'         , 'none'                   , ...
                'Name'            , 'Pulse definition'       , ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'Pixels'                 , ...
                'Position'        , [50, 50, 600, 800]       , ...
                'Tag'             , 'mri_rf_pulse_sim.app.fig_pulsedef');

            figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
            buttonBGcolor = figureBGcolor - 0.1;
            editBGcolor   = [1.0 1.0 1.0];

            % Create GUI handles : pointers to access the graphic objects
            handles               = guihandles(figHandle);
            handles.figureBGcolor = figureBGcolor;
            handles.buttonBGcolor = buttonBGcolor;
            handles.editBGcolor   = editBGcolor  ;

%             handles. = uitree(figHandle)
            
            
            % IMPORTANT
            guidata(figHandle,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            if nargout > 0
                varargout{1} = handles;
            end

        end % fcn

    end % meths

end % class
