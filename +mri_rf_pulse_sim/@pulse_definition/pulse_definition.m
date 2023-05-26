classdef pulse_definition < mri_rf_pulse_sim.base_class

    properties (GetAccess = public,  SetAccess = ?mri_rf_pulse_sim.app)

        rf_pulse mri_rf_pulse_sim.rf_pulse.sinc

        fig matlab.ui.Figure

    end % props

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

            % Create a figure
            figHandle = figure( ...
                'MenuBar'         , 'none'                   , ...
                'Toolbar'         , 'none'                   , ...
                'Name'            , 'Pulse definition'       , ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'Pixels'                 , ...
                'Position'        , [50, 50, 450, 750]       , ...
                'CloseRequestFcn' , @self.cleanup            );

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

            handles.uitree_rf_pulse = uicontrol(handles.uipanel_selection,...
                'Style','listbox',...
                'Units','Normalized',...
                'Position',[0 0 1 1],...
                'String',mri_rf_pulse_sim.get_list_rf_pulse());

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
            self.set_rf_pulse('sinc');
            self.rf_pulse.init_base_gui    (handles.uipanel_settings_base    );
            self.rf_pulse.init_specific_gui(handles.uipanel_settings_specific);
            self.rf_pulse.plot(handles.uipanel_plot);

        end % fcn

        function set_rf_pulse(self, pulse)
            switch class(pulse)
                case 'char'
                    self.rf_pulse = eval(sprintf('mri_rf_pulse_sim.rf_pulse.%s', pulse));
                otherwise
                    self.rf_pulse = pulse;
            end
            self.rf_pulse.parent = self;
        end % fcn

        function callback_update(self, ~, ~)
            self.rf_pulse.generate();
            handles = guidata(self.fig);
            self.rf_pulse.plot(handles.uipanel_plot);
            drawnow();
            notify(self.app, 'update_pulse');
        end % fcn

    end % meths

    methods(Access = protected)

        function cleanup(self,varargin)
            delete(self.rf_pulse)
            delete(self.fig)
            notify(self.app,'cleanup')
        end

    end % meths

end % class
