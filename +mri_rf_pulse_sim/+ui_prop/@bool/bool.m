classdef bool < mri_rf_pulse_sim.base_class

    properties(GetAccess = public, SetAccess = public, SetObservable, AbortSet)
        name   (1,:) char
        value  (1,1) logical
        text   (1,:) char
    end % props

    properties (GetAccess = public, SetAccess = public)
        checkbox      matlab.ui.control.UIControl
    end % props

    methods (Access = public)

        % constructor
        function self = bool(args)
            arguments
                args.name
                args.text
                args.value
            end % args

            if length(fieldnames(args)) < 1
                self = mri_rf_pulse_sim.ui_prop.bool.demo();
                return
            end

            assert(isfield(args, 'name'), 'name is required')
            self.name = args.name;

            if isfield(args, 'text' ), self.text  = args.text ; end
            if isfield(args, 'value'), self.value = args.value; end

        end % fcn

        function out = get(self)
            out = self.value;
        end % fcn
        function setTrue(self)
            self.value = true;
        end % fcn
        function setFalse(self)
            self.value = false;
        end % fcn
        function set(self, in)
            self.value = in;
        end % fcn

        function add_uicontrol(self,container,rect)

            if nargin < 3
                rect = [0 0 1 1];
            end

            pos_chk_raw = [0   0 0.2 1];
            pos_txt_raw = [0.2 0 0.8 1];

            pos_chk = [pos_chk_raw(1)+rect(1) pos_chk_raw(2)+rect(2) pos_chk_raw(3)*rect(3) pos_chk_raw(4)*rect(4)];
            pos_txt = [pos_txt_raw(1)+rect(1) pos_txt_raw(2)+rect(2) pos_txt_raw(3)*rect(3) pos_txt_raw(4)*rect(4)];

            self.checkbox = uicontrol(container,...
                'Style'          , 'checkbox'                 ,...
                'Units'          , 'normalized'               ,...
                'Position'       , pos_chk                    ,...
                'Value'          , self.value                 ,...
                'BackgroundColor', container.BackgroundColor  ,...
                'Callback'        , @self.callback_update      ...
                );

            uicontrol(container,...
                'Style'           , 'text'                    ,...
                'String'          , self.text                 ,...
                'Units'           , 'normalized'              ,...
                'Position'        , pos_txt                   ,...
                'BackgroundColor' , container.BackgroundColor  ...
                );

            addlistener(self, 'value', 'PostSet', @self.postset_update);

        end % fcn

        function displayRep = compactRepresentationForSingleLine(self,displayConfiguration,width)
            txt = sprintf('%s = %g (%s)', ...
                self.name, self.value, self.text);
            displayRep = widthConstrainedDataRepresentation(self,displayConfiguration,width,...
                StringArray=txt,AllowTruncatedDisplayForScalar=true);
        end % dcn

    end % meths

    methods (Static)

        function check = demo()

            check = mri_rf_pulse_sim.ui_prop.bool(name='my_bool', text='demo for a boolean', value=true);

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

            handles.uipanel_demo = uipanel(figHandle,...
                'Title','demo panel',...
                'BackgroundColor',figureBGcolor,...
                'Units','normalized',...
                'Position',[0.2 0.2 0.4 0.2]);

            % IMPORTANT
            guidata(figHandle,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            check.add_uicontrol(handles.uipanel_demo);

        end % fcn

    end % meths

    methods(Access = protected)

        function callback_update(self, src, ~)
            prev_value = self.value;
            try
                self.value = src.Value;
            catch
                src.Value = prev_value;
            end
        end % fcn

        function postset_update(self, ~, ~)
            new_value           = self.value;
            self.checkbox.Value = new_value;

            self.notify_parent();
        end % fcn

    end % meths

end % class
