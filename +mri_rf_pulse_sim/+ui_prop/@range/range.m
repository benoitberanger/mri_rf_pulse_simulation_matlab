classdef range < handle

    properties(GetAccess = public, SetAccess = public, SetObservable)
        name   (1,:) char

        min    (1,1) double {mustBeFinite}
        max    (1,1) double {mustBeFinite}
        N      (1,1) double {mustBeFinite}
        select (1,1) double {mustBeFinite}

        scale  (1,1) double {mustBeFinite} = 1
    end % props

    properties(GetAccess = public, SetAccess = public, Dependent)
        vect         (1,:) double
        middle_idx   (1,1) double
        middle_value (1,1) double
    end % props

    properties (GetAccess = public, SetAccess = public)
        edit_min      matlab.ui.control.UIControl
        edit_max      matlab.ui.control.UIControl
        edit_N        matlab.ui.control.UIControl
        edit_select   matlab.ui.control.UIControl
        slider        matlab.ui.control.UIControl
    end % props

    methods % for Dependent properties

        function value = get.vect(self)
            value = linspace(self.min, self.max, self.N);
        end

        function value = get.middle_idx(self)
            value = round(self.N/2);
        end % fcn

        function value = get.middle_value(self)
            value = self.vect(self.middle_idx);
        end % fcn

        function set.vect(self,value)
            self.min    =    min(value); %#ok<CPROPLC>
            self.max    =    max(value); %#ok<CPROPLC>
            self.N      = length(value);
            self.select =        value(round(self.N/2));
        end

    end % meths

    methods (Access = public)

        % constructor
        function self = range(varargin)
            if nargin < 1
                self = mri_rf_pulse_sim.ui_prop.range.demo();
                return
            end

            if     nargin == 1
                self.name  = varargin{1};
            elseif nargin == 2
                self.name  = varargin{1};
                self.vect  = varargin{2};
            elseif nargin == 3
                self.name  = varargin{1};
                self.vect  = varargin{2};
                self.scale = varargin{3};
            else
                error('@mri_rf_pulse_sim.ui_prop.range constructor -> 1 argument, the ''name'' ')
            end
        end % fcn

        function add_uicontrol_setup(self,container)
            props   = {'min'            'max'             'N'};
            scales  = [ self.scale       self.scale        1 ];

            spacing = 1/length(props);

            for p = 1 : length(props)
                prop = props{p};

                uicontrol(container,...
                    'Style'          , 'text'                          ,...
                    'String'         , prop                            ,...
                    'Units'          , 'normalized'                    ,...
                    'BackgroundColor', container.BackgroundColor       ,...
                    'Position'       , [(p-1)*spacing 0.6 spacing 0.4]  ...
                    );

                tag = sprintf('edit_%s',prop);
                self.(tag) = uicontrol(container,...
                    'Tag'             , tag                              ,...
                    'Style'           , 'edit'                           ,...
                    'String'          , num2str(self.(prop) * scales(p)) ,...
                    'Units'           , 'normalized'                     ,...
                    'BackgroundColor' , [1 1 1]                          ,...
                    'Position'        , [(p-1)*spacing 0 spacing 0.6]    ,...
                    'Callback'        , @self.callback_update_setup      ,...
                    'UserData'        , scales(p)                         ...
                    );

                addlistener(self, prop, 'PostSet', @self.postset_update_setup);

            end

        end % fcn

        function add_uicontrol_select(self,container)
            uicontrol(container,...
                'Style'          , 'text'                      ,...
                'Units'          , 'normalized'                ,...
                'Position'       , [0 0 0.2 1]                 ,...
                'BackgroundColor', container.BackgroundColor   ,...
                'String'         , sprintf('%s = ', self.name)  ...
                );
            self.edit_select = uicontrol(container,...
                'Style'          , 'edit'                       ,...
                'BackgroundColor', [1 1 1]                      ,...
                'String'         , num2str(self.middle_value)   ,...
                'Units'          , 'normalized'                 ,...
                'Position'       , [0.2 0 0.2 1]                ,...
                'Callback'       , @self.callback_update_select  ...
                );
            self.slider = uicontrol(container,...
                'Style'          , 'slider'                     ,...
                'Units'          ,'normalized'                  ,...
                'Position'       , [0.4 0 0.6 1]                ,...
                'Min'            , self.min                     ,...
                'Max'            , self.max                     ,...
                'Value'          , self.middle_value            ,...
                'SliderStep'     , [1/(self.N-1) 1/(self.N-1)]  ,...
                'Callback'       , @self.callback_update_select  ...
                );
            addlistener(self, 'select', 'PostSet', @self.postset_update_select);
        end % fcn

    end % meths

    methods (Static)

        function self = demo()

            self = mri_rf_pulse_sim.ui_prop.range('demo_range', linspace(-10,10,11)/1000, 1000);

            % Create a figure
            figHandle = figure( ...
                'MenuBar'         , 'none'                   , ...
                'Toolbar'         , 'none'                   , ...
                'Name'            , sprintf('%s.demo()',mfilename)  , ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'Pixels'                 , ...
                'Position'        , [50, 50, 450, 350]       );

            figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
            buttonBGcolor = figureBGcolor - 0.1;
            editBGcolor   = [1.0 1.0 1.0];

            % Create GUI handles : pointers to access the graphic objects
            handles               = guihandles(figHandle);
            handles.fig           = figHandle;
            handles.figureBGcolor = figureBGcolor;
            handles.buttonBGcolor = buttonBGcolor;
            handles.editBGcolor   = editBGcolor  ;

            handles.uipanel_setup = uipanel(figHandle,...
                'Title','Setup',...
                'BackgroundColor',figureBGcolor,...
                'Units','normalized',...
                'Position',[0 0.5 1 0.5]);

            handles.uipanel_select = uipanel(figHandle,...
                'Title','Interact',...
                'BackgroundColor',figureBGcolor,...
                'Units','normalized',...
                'Position',[0 0 1 0.5]);

            % IMPORTANT
            guidata(figHandle,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            self.add_uicontrol_setup (handles.uipanel_setup );
            self.add_uicontrol_select(handles.uipanel_select);

        end % fcn

    end % meths

    methods(Access = protected)

        function callback_update_setup(self, src, ~)
            res = strsplit(src.Tag,'_');
            prop_name = res{2};
            prev_value = self.(prop_name);
            try
                self.(prop_name) = str2double(src.String) / src.UserData;
            catch
                src.String = num2str(prev_value * src.UserData);
            end
        end % fcn

        function postset_update_setup(self, metaProp, ~)
            prop_name     = metaProp.Name;
            new_value     = self.(prop_name);
            ui_obj        = self.(sprintf('edit_%s',prop_name));
            ui_obj.String = num2str(new_value * ui_obj.UserData);

            self.slider.Min        = self.min;
            self.slider.Max        = self.max;
            self.slider.SliderStep = [1/(self.N-1) 1/(self.N-1)];
            self.select            = self.middle_value;
        end % fcn

        function callback_update_select(self, src, ~)
            switch src.Style
                case 'edit'
                    new_value = str2double(src.String) / self.scale;
                case 'slider'
                    new_value = src.Value;
            end

            [~, closest_idx] = min(abs(self.vect - new_value)); %#ok<CPROPLC>
            new_value = self.vect(closest_idx);

            self.edit_select.String = num2str(new_value * 1000);
            self.slider.Value = new_value;

            self.select = new_value;
        end % fcn

        function postset_update_select(self, ~, ~)
            new_value               = self.select;
            self.edit_select.String = num2str(new_value * self.scale);
            self.slider.Value       = new_value;
        end % fcn

    end % meths

end % class