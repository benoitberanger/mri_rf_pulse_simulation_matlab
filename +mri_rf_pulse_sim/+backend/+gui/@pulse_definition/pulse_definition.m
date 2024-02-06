classdef pulse_definition < mri_rf_pulse_sim.backend.base_class

    properties (GetAccess = public,  SetAccess = ?mri_rf_pulse_sim.app)

        rf_pulse

        fig matlab.ui.Figure

    end % props

    methods
        function set.rf_pulse(self,value)
            assert(isa(value,'mri_rf_pulse_sim.backend.rf_pulse.abstract'))
            self.rf_pulse = value;
        end
    end

    methods (Access = public)

        function self = pulse_definition(varargin)
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

            fig_pos = mri_rf_pulse_sim.backend.gui.get_fig_pos();

            % Create a figure
            figHandle = figure( ...
                'MenuBar'         , 'none'                   , ...
                'Toolbar'         , 'none'                   , ...
                'Name'            , 'Pulse definition'       , ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'normalized'             , ...
                'Position'        , fig_pos.(mfilename)      , ...
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

            handles.listbox_rf_pulse = uicontrol(handles.uipanel_selection,...
                'Style','listbox',...
                'Units','Normalized',...
                'Position',[0 0 1 1],...
                'String',mri_rf_pulse_sim.backend.rf_pulse.get_list(),...
                'Callback',@self.callback_set_rf_pulse);

            handles.uipanel_settings_specific = uipanel(handles.uipanel_settings,...
                'Title','Pulse specific',...
                'Units','Normalized',...
                'Position',[0 0 1 0.7],...
                'BackgroundColor',figureBGcolor);

            handles.uipanel_settings_base = uipanel(handles.uipanel_settings,...
                'Title', 'Base',...
                'Units','Normalized',...
                'Position',[0 0.7 1 0.3],...
                'BackgroundColor',figureBGcolor);

            % IMPORTANT
            guidata(figHandle,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            self.fig = figHandle;

            % initialize with default values
            idx_sinc = find(strcmp(handles.listbox_rf_pulse.String,'sinc'));
            handles.listbox_rf_pulse.Value = idx_sinc;
            self.callback_set_rf_pulse(handles.listbox_rf_pulse);

        end % fcn

        function pulse_obj = set_rf_pulse(self, pulse)

            % delete window if necessary
            if ~isempty(self.app.window_definition) && ~isempty(self.app.window_definition.fig)
                delete(self.app.window_definition.fig);
            end

            % clean previous plot
            handles = guidata(self.fig);
            delete(handles.uipanel_settings_base    .Children)
            delete(handles.uipanel_settings_specific.Children)
            delete(handles.uipanel_plot             .Children)

            rf_rel_path = 'mri_rf_pulse_sim.rf_pulse.';
            
            % instantiate OR assign pulse
            switch class(pulse)
                case 'char'
                    if any(pulse == filesep)
                        split = strsplit(pulse, filesep);
                        self.rf_pulse = eval(sprintf('%S%s.%s', rf_rel_path, split{1}, split{2}));
                    else
                        self.rf_pulse = eval(sprintf('%s%s', rf_rel_path, pulse));
                    end
                otherwise
                    self.rf_pulse = pulse;
            end
            self.rf_pulse.parent = self;
            self.rf_pulse.app    = self.app;

            % plot pulse
            self.rf_pulse.init_base_gui    (handles.uipanel_settings_base    );
            self.rf_pulse.init_specific_gui(handles.uipanel_settings_specific);
            self.rf_pulse.plot(handles.uipanel_plot);

            % update list of pulse : highlight the fresh pulse
            simplified_object_name = strrep(class(self.rf_pulse),rf_rel_path,'');
            simplified_object_name = strrep(simplified_object_name,'.',filesep);
            idx = find( strcmp(handles.listbox_rf_pulse.String, simplified_object_name) );
            if idx
                handles.listbox_rf_pulse.Value = idx;
            else
                handles.listbox_rf_pulse.Value = [];
            end

            notify(self.app, 'update_pulse');
            pulse_obj = self.rf_pulse;
        end % fcn

        function callback_update(self, ~, ~)
            self.rf_pulse.generate();
            handles = guidata(self.fig);
            delete(handles.uipanel_plot.Children)
            self.rf_pulse.plot(handles.uipanel_plot);
            drawnow();
            notify(self.app, 'update_pulse');
        end % fcn

    end % meths

    methods(Access = protected)

        function callback_set_rf_pulse(self,hObject,~)
            new_pulse_name = hObject.String{hObject.Value};
            self.set_rf_pulse(new_pulse_name);
        end % fcn

        function callback_cleanup(self,varargin)
            delete(self.fig)
            notify(self.app,'cleanup')
        end % fcn

    end % meths

end % class
