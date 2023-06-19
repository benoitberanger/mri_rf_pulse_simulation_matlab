classdef scalar < mri_rf_pulse_sim.base_class

    properties(GetAccess = public, SetAccess = public, SetObservable, AbortSet)
        name   (1,:) char
        value  (1,1) double
        unit         char
        scale  (1,1) double {mustBeFinite} = 1
    end % props

    properties (GetAccess = public, SetAccess = public)
        edit         matlab.ui.control.UIControl
    end % props

    methods (Access = public)

        % constructor
        function self = scalar(args)
            arguments
                args.name
                args.value
                args.unit
                args.scale
                args.parent
            end % args

            if length(fieldnames(args)) < 1
                self = mri_rf_pulse_sim.ui_prop.scalar.demo();
                return
            end

            assert(isfield(args,  'name'),  'name is required')
            assert(isfield(args, 'value'), 'value is required')
            self.name  = args.name;
            self.value = args.value;

            if isfield(args, 'unit'  ), self.unit   = args.unit  ; end
            if isfield(args, 'scale' ), self.scale  = args.scale ; end
            if isfield(args, 'parent'), self.parent = args.parent; end
        end % fcn

        function out = double(self)
            out = self.value;
        end % fcn

        function out = plus(LEFT, RIGHT)
            out = double(LEFT) + double(RIGHT);
        end % fcn
        function out = minus(LEFT, RIGHT)
            out = double(LEFT) - double(RIGHT);
        end % fcn

        function out = mtimes(LEFT, RIGHT)
            out = double(LEFT) * double(RIGHT);
        end % fcn
        function out = mrdivide(LEFT, RIGHT)
            out = double(LEFT) / double(RIGHT);
        end % fcn

        function out = uplus(RIGHT)
            out = +double(RIGHT);
        end % fcn
        function out = uminus(RIGHT)
            out = -double(RIGHT);
        end % fcn

        function out = get(self)
            out = self.value * self.scale;
        end % fcn
        function set(self, in)
            self.value = in;
        end % fcn

        function add_uicontrol(self,container,rect)

            if nargin < 3
                rect = [0 0 1 1];
            end

            pos_text = mri_rf_pulse_sim.ui_prop.compose_rect([0.0  0.0  0.5  1.0], rect);
            pos_edit = mri_rf_pulse_sim.ui_prop.compose_rect([0.5  0.0  0.5  1.0], rect);

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

            addlistener(self, 'value', 'PostSet', @self.postset_update);

        end % fcn

        function displayRep = compactRepresentationForSingleLine(self,displayConfiguration,width)
            txt = sprintf('%g (%g %s)', ...
                self.value, self.value*self.scale, self.unit);
            displayRep = widthConstrainedDataRepresentation(self,displayConfiguration,width,...
                StringArray=txt,AllowTruncatedDisplayForScalar=true);
        end % dcn

    end % meths

    methods (Static)

        function scalars = demo()

            time = mri_rf_pulse_sim.ui_prop.scalar(...
                name  ='time'  ,...
                value = 1/1000 ,...
                unit  = 'ms'   ,...
                scale = 1000   );

            v1   = mri_rf_pulse_sim.ui_prop.scalar(name='v1'  , value=1     , unit='m/s'             );
            v2   = mri_rf_pulse_sim.ui_prop.scalar(name='v2'  , value=1/1000, unit='mm/s', scale=1000);
            p1   = mri_rf_pulse_sim.ui_prop.scalar(name='p1'  , value=49.3                           );
            p2   = mri_rf_pulse_sim.ui_prop.scalar(name='p2'  , value=666                            );

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

        function add_uicontrol_multi_scalar(container,scalars, rect)
            if nargin < 3
                rect = [0 0 1 1];
            end
            
            scalars = fliplr(scalars);
            spacing = 1/numel(scalars);
            for s = 1 : length(scalars)
                pos = mri_rf_pulse_sim.ui_prop.compose_rect([0 (s-1)*spacing 1 spacing],rect);
                scalars(s).add_uicontrol(container, pos);
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
