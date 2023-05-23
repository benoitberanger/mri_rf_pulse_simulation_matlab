classdef simulation_parameters < handle

    properties(GetAccess = public, SetAccess = public, SetObservable)

        dZ  (1,:) double  = linspace(-30,+30,61) * 1e-3                    % [m] slice (spin) position
        dB0 (1,:) double  = 0                                              % [ppm] off-resonance

    end % props

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)

        app mri_rf_pulse_sim.app
        fig matlab.ui.Figure

    end % props

    methods (Access = public)

        function self = simulation_parameters(varargin)
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
                'Name'            , 'mri_rf_pulse_sim.app.simulation_parameters', ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'Pixels'                 , ...
                'Position'        , [500, 50, 300, 350]       , ...
                'Tag'             , 'mri_rf_pulse_sim.app.pulse_definition');

            figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
            buttonBGcolor = figureBGcolor - 0.1;
            editBGcolor   = [1.0 1.0 1.0];

            % Create GUI handles : pointers to access the graphic objects
            handles               = guihandles(figHandle);
            handles.fig           = figHandle;
            handles.figureBGcolor = figureBGcolor;
            handles.buttonBGcolor = buttonBGcolor;
            handles.editBGcolor   = editBGcolor  ;

            handles.uipanel_dB0 = uipanel(figHandle,...
                'Title','dB0 [ppm] : off-resonance',...
                'Units','Normalized',...
                'Position',[0 0 1 0.5],...
                'BackgroundColor',figureBGcolor);

            handles.uipanel_dZ = uipanel(figHandle,...
                'Title','dZ [mm] : slice (spin) position',...
                'Units','Normalized',...
                'Position',[0 0.5 1 0.5],...
                'BackgroundColor',figureBGcolor);

            handles = self.add_gui_ranged_parameters('dZ' , 1e-3, handles.uipanel_dZ , handles);
            handles = self.add_gui_ranged_parameters('dB0', 1   , handles.uipanel_dB0, handles);

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

        function handles = add_gui_ranged_parameters(self, prop, scale, container, handles)
            fields      = {'min'            'max'             'N'                 };
            init_values = [ min(self.(prop)) max(self.(prop)) length(self.(prop)) ];
            scales      = [ scale            scale            1                   ];

            spacing = 1/length(fields);

            for f = 1 : length(fields)
                field = fields{f};

                name = sprintf('edit_%s',field);
                handles.(name) = uicontrol(container,...
                    'Tag',name,...
                    'Style','edit',...
                    'String',init_values(f) / scales(f),...
                    'Units','normalized',...
                    'BackgroundColor',handles.editBGcolor,...
                    'Position',[(f-1)*spacing 0 spacing 0.6],...
                    'Callback',@(varargin) disp(name),...
                    'UserData',scales(f)...
                    );

                handles.(sprintf('text_%s',field)) = uicontrol(container,...
                    'Style','text',...
                    'String',field,...
                    'Units','normalized',...
                    'BackgroundColor',handles.figureBGcolor,...
                    'Position',[(f-1)*spacing 0.6 spacing 0.1]);
            end
        end % fcn

    end % meths

end % class
