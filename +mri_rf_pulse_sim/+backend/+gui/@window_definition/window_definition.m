classdef window_definition < mri_rf_pulse_sim.backend.base_class

    properties (GetAccess = public,  SetAccess = ?mri_rf_pulse_sim.app)

        window

        fig matlab.ui.Figure

    end % props

    methods
        function set.window(self,value)
            assert(isa(value,'mri_rf_pulse_sim.backend.window.abstract'))
            self.window = value;
        end
    end
    
    methods (Access = public)

        function self = window_definition(varargin)
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
                'Name'            , 'Pulse window'           , ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'normalized'             , ...
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

            handles.uipanel_plot = uipanel(figHandle,...
                'Title','Plot',...
                'Units','Normalized',...
                'Position',[0 0 1 0.7],...
                'BackgroundColor',figureBGcolor);

            handles.uipanel_selection = uipanel(figHandle,...
                'Title','Selection',...
                'Units','Normalized',...
                'Position',[0 0.7 0.4 0.3],...
                'BackgroundColor',figureBGcolor);

            handles.uipanel_settings = uipanel(figHandle,...
                'Title','Settings',...
                'Units','Normalized',...
                'Position',[0.4 0.7 0.6 0.3],...
                'BackgroundColor',figureBGcolor);

            handles.listbox_window = uicontrol(handles.uipanel_selection,...
                'Style','listbox',...
                'Units','Normalized',...
                'Position',[0 0 1 1],...
                'String',mri_rf_pulse_sim.backend.window.get_list(),...
                'Callback',@self.callback_set_window);

            % IMPORTANT
            guidata(figHandle,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            self.fig = figHandle;

            % initialize with default values
            idx_hanning = find(strcmp(handles.listbox_window.String,'hanning'));
            handles.listbox_window.Value = idx_hanning;
            self.set_window('hanning');

        end % fcn

        function callback_update(self,varargin) % update comes from the @window
            handles = guidata(self.fig);
            delete(handles.uipanel_plot.Children)
            self.window.plot(handles.uipanel_plot);
            notify(self.app, 'update_window');
        end % fcn

    end % meths

    methods (Access = protected)

        function callback_set_window(self,hObject,~)
            new_window_name = hObject.String{hObject.Value};
            self.set_window(new_window_name);
            notify(self.app, 'update_window');
        end % fcn

        function set_window(self, win)
            handles = guidata(self.fig);
            delete(handles.uipanel_settings.Children)
            delete(handles.uipanel_plot    .Children)

            switch class(win)
                case 'char'
                    self.window = eval(sprintf('mri_rf_pulse_sim.window.%s', win));
                otherwise
                    self.window = win;
            end
            self.window.parent = self;

            self.window.init_gui(handles.uipanel_settings)
        end % fcn

        function callback_cleanup(self,varargin)
            delete(self.fig)
            notify(self.app,'update_window')
        end % fcn

    end % meths

end % class
