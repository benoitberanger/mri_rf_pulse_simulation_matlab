classdef simulation_parameters < handle

    properties(GetAccess = public, SetAccess = public, SetObservable)

        dZ__min  (1,1) double {mustBeFinite} = -10 * 1e-3                  % [m] slice (spin) position minimum
        dZ__max  (1,1) double {mustBeFinite} = +10 * 1e-3                  % [m] slice (spin) position maximum
        dZ__N    (1,1) double {mustBeFinite} = 201                         % [] number of slice positons
        dB0__min (1,1) double {mustBeFinite} =   0                         % [ppm] off-resonance minimum
        dB0__max (1,1) double {mustBeFinite} =   0                         % [ppm] off-resonance maximum
        dB0__N   (1,1) double {mustBeFinite} =   1                         % [] number of off-resonances

        auto_simplot (1,1) logical = true                                  % state of the GUI checkbox

    end % props

    properties(GetAccess = public, SetAccess = public, Dependent)

        dZ  (1,:) double                                                   % [m] slice (spin) position vector
        dB0 (1,:) double                                                   % [ppm] off-resonance vector

    end % props

    properties (GetAccess = public, SetAccess = protected, Hidden)
        ui__dZ__min      matlab.ui.control.UIControl                       % pointer to the GUI object
        ui__dZ__max      matlab.ui.control.UIControl                       % pointer to the GUI object
        ui__dZ__N        matlab.ui.control.UIControl                       % pointer to the GUI object
        ui__dB0__min     matlab.ui.control.UIControl                       % pointer to the GUI object
        ui__dB0__max     matlab.ui.control.UIControl                       % pointer to the GUI object
        ui__dB0__N       matlab.ui.control.UIControl                       % pointer to the GUI object

        ui__auto_simplot matlab.ui.control.UIControl                       % pointer to the GUI object
    end % props

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)
        app mri_rf_pulse_sim.app
        fig matlab.ui.Figure
    end % props

    methods % for Dependent properties
        function value = get.dZ(self)
            value = linspace(self.dZ__min, self.dZ__max, self.dZ__N);
        end
        function value = get.dB0(self)
            value = linspace(self.dB0__min, self.dB0__max, self.dB0__N);
        end
        function set.dZ(self,value)
            self.dZ__min =    min(value);
            self.dZ__max =    max(value);
            self.dZ__N   = length(value);
        end
        function set.dB0(self,value)
            self.dB0__min =    min(value);
            self.dB0__max =    max(value);
            self.dB0__N   = length(value);
        end
    end % meths

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
                'Name'            , 'Simulation parameters'  , ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'Pixels'                 , ...
                'Position'        , [500, 50, 300, 350]       , ...
                'Tag'             , 'mri_rf_pulse_sim.app.simulation_parameters');

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
                'Position',[0 0 1 0.2],...
                'BackgroundColor',figureBGcolor);

            handles.uipanel_dZ = uipanel(figHandle,...
                'Title','dZ [mm] : slice (spin) position',...
                'Units','Normalized',...
                'Position',[0 0.2 1 0.2],...
                'BackgroundColor',figureBGcolor);

            handles = self.add_gui_ranged_parameters('dZ' , 1e-3, handles.uipanel_dZ , handles);
            handles = self.add_gui_ranged_parameters('dB0', 1   , handles.uipanel_dB0, handles);

            handles.uipanel_controls = uipanel(figHandle,...
                'Title','Controls',...
                'Units','Normalized',...
                'Position',[0 0.4 1 0.6],...
                'BackgroundColor',figureBGcolor);

            handles.checkbox_auto_simplot = uicontrol(handles.uipanel_controls,...
                'Style','checkbox',...,
                'BackgroundColor',handles.figureBGcolor,...
                'Value',true,...
                'String','auto sim+plot',...
                'Units','normalized',...
                'Position',[0 0.9 0.5 0.1],...
                'Callback',@self.callback_auto_simplot);
            self.ui__auto_simplot = handles.checkbox_auto_simplot;
            addlistener(self, 'auto_simplot', 'PostSet', @self.gui_prop_changed);

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
            fields      = {'min'            'max'             'N'};
            scales      = [ scale            scale             1 ];

            spacing = 1/length(fields);

            for f = 1 : length(fields)
                field = fields{f};

                handles.(sprintf('text_%s',field)) = uicontrol(container,...
                    'Style','text',...
                    'String',field,...
                    'Units','normalized',...
                    'BackgroundColor',handles.figureBGcolor,...
                    'Position',[(f-1)*spacing 0.6 spacing 0.4]);

                name = sprintf('%s__%s',prop,field);
                uiname = sprintf('edit__%s',name);
                handles.(uiname) = uicontrol(container,...
                    'Tag',uiname,...
                    'Style','edit',...
                    'String',num2str(self.(sprintf('%s__%s',prop,field)) / scales(f)),...
                    'Units','normalized',...
                    'BackgroundColor',handles.editBGcolor,...
                    'Position',[(f-1)*spacing 0 spacing 0.6],...
                    'Callback',@self.callback_update_value,...
                    'UserData',scales(f)...
                    );
                self.(sprintf('ui__%s', name)) = handles.(uiname);

                addlistener(self, name, 'PostSet', @self.gui_prop_changed);
            end
        end % fcn

        % gui callback to propagate the fresh value to the underlying
        % object in the app
        function callback_update_value(self, src, ~)
            res = strsplit(src.Tag,'__');
            prop_name = [res{2} '__' res{3}];
            prev_value = self.(prop_name);
            try
                self.(prop_name) = str2double(src.String) * src.UserData;
            catch
                src.String = num2str(prev_value * 1/src.UserData);
            end
        end % fcn

        function callback_auto_simplot(self, src, ~)
            self.auto_simplot = src.Value;
            if self.auto_simplot
                self.app.simplot();
            end
        end % fcn

        % This method is called when the property is Set. It can be
        % from the command line, from a script, from a function...
        % It triggers the re-generation of the pulse, and a GUI update.
        % It also happens when the value is modified in the GUI : this
        % is useless, but it's a neglictable overhead for the moment.
        function gui_prop_changed(self, metaProp, eventData)
            prop_name      = metaProp.Name;
            sim            = eventData.AffectedObject;
            new_value      = sim.(prop_name);
            gui_obj        = sim.(sprintf('ui__%s', prop_name));
            switch gui_obj.Style
                case 'edit'
                    gui_obj.String = num2str(new_value * 1/gui_obj.UserData);
                case 'checkbox'
                    gui_obj.Value = new_value;
                otherwise
                    error('sync not coded yet')
            end % switch
            if self.app.simulation_parameters.auto_simplot
                self.app.simplot();
            end
        end % fcn

    end % meths

end % class
