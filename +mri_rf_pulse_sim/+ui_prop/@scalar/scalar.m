classdef scalar < mri_rf_pulse_sim.base_class

    properties(GetAccess = public, SetAccess = public, SetObservable, AbortSet)
        name   (1,:) char
        value  (1,1) double
        unit         char
        scale  (1,1) double {mustBeFinite} = 1
    end % props

    properties (GetAccess = public, SetAccess = public)
        edit     matlab.ui.control.UIControl
        listener event.listener
    end % props

    methods (Access = public)

        % constructor
        function self = scalar(varargin)
            if nargin < 1
                self = mri_rf_pulse_sim.ui_prop.scalar.demo();
                return
            end

            if     nargin == 1
                self.name  = varargin{1};
            elseif nargin == 2
                self.name  = varargin{1};
                self.value = varargin{2};
            elseif nargin == 3
                self.name  = varargin{1};
                self.value = varargin{2};
                self.unit  = varargin{3};
            elseif nargin == 4
                self.name  = varargin{1};
                self.value = varargin{2};
                self.unit  = varargin{3};
                self.scale = varargin{4};
            else
                error('%s constructor -> 1,2,3,4 arguments', mfilename)
            end
        end % fcn

        function add_uicontrol(self,container,rect)

            if nargin < 3
                rect = [0 0 1 1];
            end

            pos_text_raw = [0   0 0.5 1];
            pos_edit_raw = [0.5 0 0.5 1];

            pos_text = [pos_text_raw(1)+rect(1) pos_text_raw(2)+rect(2) pos_text_raw(3)*rect(3) pos_text_raw(4)*rect(4)];
            pos_edit = [pos_edit_raw(1)+rect(1) pos_edit_raw(2)+rect(2) pos_edit_raw(3)*rect(3) pos_edit_raw(4)*rect(4)];

            if self.unit
                txt = sprintf('%s (%s)', self.name, self.unit);
            else
                txt = sprintf('%s', self.name);
            end

            uicontrol(container,...
                'Style'          , 'text'                          ,...
                'String'         ,  txt                            ,...
                'Units'          , 'normalized'                    ,...
                'BackgroundColor', container.BackgroundColor       ,...
                'Position'       , pos_text                         ...
                );

            self.edit = uicontrol(container,...
                'Style'           , 'edit'                           ,...
                'String'          , num2str(self.value * self.scale) ,...
                'Units'           , 'normalized'                     ,...
                'BackgroundColor' , [1 1 1]                          ,...
                'Position'        , pos_edit                         ,...
                'Callback'        , @self.callback_update             ...
                );

            self.listener = addlistener(self, 'value', 'PostSet', @self.postset_update);

        end % fcn

        function delete(self)
            delete(self.delete(self.listener))
        end % fcn

    end % meths

    methods (Static)

        function scalars = demo()

            time = mri_rf_pulse_sim.ui_prop.scalar('time', 1/1000,   'ms', 1000);

            v1   = mri_rf_pulse_sim.ui_prop.scalar('v1'  , 1     ,  'm/s'      );
            v2   = mri_rf_pulse_sim.ui_prop.scalar('v2'  , 1/1000, 'mm/s', 1000);
            p1   = mri_rf_pulse_sim.ui_prop.scalar('p1'  , 49.3                );
            p2   = mri_rf_pulse_sim.ui_prop.scalar('p2'                        );

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

            handles.uipanel_1_scalar = uipanel(figHandle,...
                'Title','1 scalar',...
                'BackgroundColor',figureBGcolor,...
                'Units','normalized',...
                'Position',[0 0.8 1 0.2]);

            handles.uipanel_many_scalar = uipanel(figHandle,...
                'Title','Many scalar',...
                'BackgroundColor',figureBGcolor,...
                'Units','normalized',...
                'Position',[0 0 1 0.8]);

            % IMPORTANT
            guidata(figHandle,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            time.add_uicontrol(handles.uipanel_1_scalar);
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(handles.uipanel_many_scalar,[v1,v2,p1,p2]);

            scalars = [time, v1, v2, p1, p2];

        end % fcn

        function add_uicontrol_multi_scalar(container,scalars)
            scalars = fliplr(scalars);
            spacing = 1/numel(scalars);
            for s = 1 : length(scalars)
                rect = [0 (s-1)*spacing 1 spacing];
                scalars(s).add_uicontrol(container, rect);
            end
        end % fcn

    end % meths

    methods(Access = protected)

        function callback_update(self, src, ~)
            prev_value = self.value;
            try
                self.value = str2double(src.String) / self.scale;
            catch
                src.String = num2str(prev_value * self.scale);
            end
        end % fcn

        function postset_update(self, ~, ~)
            new_value        = self.value;
            self.edit.String = num2str(new_value * self.scale);

            self.notify_parent();
        end % fcn

    end % meths

end % class
