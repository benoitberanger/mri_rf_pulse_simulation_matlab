classdef bool < mri_rf_pulse_sim.backend.base_class

    properties(GetAccess = public, SetAccess = public, SetObservable, AbortSet)
        name    (1,:) char
        value   (1,1) logical
        text    (1,:) char
        visible (1,1) string {mustBeMember(visible,["on","off"])} = "on"
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        repr
    end % props

    methods % no attribute for dependent properties
        function value = get.repr(self)
            value = self.summary();
        end
    end % methods

    properties (GetAccess = public, SetAccess = public)
        checkbox           matlab.ui.control.UIControl
        listener__checkbox event.listener
    end % props

    methods (Access = public)

        % constructor
        function self = bool(args)
            arguments
                args.name
                args.text
                args.value
                args.visible
                args.parent
            end % args

            if length(fieldnames(args)) < 1
                return
            end

            assert(isfield(args, 'name'), 'name is required')
            self.name = args.name;

            if isfield(args, 'text'   ), self.text    = args.text   ; end
            if isfield(args, 'value'  ), self.value   = args.value  ; end
            if isfield(args, 'visible'), self.visible = args.visible; end
            if isfield(args, 'parent' ), self.parent  = args.parent ; end
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

            pos_chk = mri_rf_pulse_sim.backend.gui.compose_rect([0.0  0.0  0.2  1.0],rect);
            pos_txt = mri_rf_pulse_sim.backend.gui.compose_rect([0.2  0.0  0.8  1.0],rect);

            self.checkbox = uicontrol(container,...
                'Style'              , 'checkbox'                 ,...
                'Units'              , 'normalized'               ,...
                'Position'           , pos_chk                    ,...
                'Value'              , self.value                 ,...
                'Visible'            , self.visible               ,...
                'BackgroundColor'    , container.BackgroundColor  ,...
                'Callback'           , @self.callback_update       ...
                );

            uicontrol(container,...
                'Style'              , 'text'                    ,...
                'String'             , self.text                 ,...
                'Units'              , 'normalized'              ,...
                'Position'           , pos_txt                   ,...
                'HorizontalAlignment','left'                     ,...
                'Visible'            , self.visible              ,...
                'BackgroundColor'    , container.BackgroundColor  ...
                );

            self.listener__checkbox = addlistener(self, 'value', 'PostSet', @self.postset_update);

        end % fcn

        function txt = summary(self)
            txt = sprintf('%g [bool]', self.value);
        end

        function displayRep = compactRepresentationForSingleLine(self,displayConfiguration,width)
            displayRep = widthConstrainedDataRepresentation(self,displayConfiguration,width,...
                StringArray=self.repr,AllowTruncatedDisplayForScalar=true);
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
            if ~ishandle(self.checkbox), return, end

            new_value           = self.value;
            self.checkbox.Value = new_value;

            self.notify_parent();
        end % fcn

    end % meths

end % class
