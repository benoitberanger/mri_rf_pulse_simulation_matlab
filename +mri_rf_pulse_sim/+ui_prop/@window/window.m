classdef window < mri_rf_pulse_sim.backend.base_class

    properties(GetAccess = public, SetAccess = public, SetObservable, AbortSet)
        list          mri_rf_pulse_sim.ui_prop.list
        name    (1,:) char
        child
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
        toggle_button matlab.ui.control.UIControl
    end % props

    properties (GetAccess = private, SetAccess = private)
        label_none = "<None>"
    end % props

    methods (Access = public)

        % constructor
        function self = window(args)
            arguments
                args.name
                args.list
                args.value
                args.child
                args.visible
                args.parent
            end % args

            window_list = mri_rf_pulse_sim.backend.window.get_list();
            window_list = self.label_none + window_list;
            self.list   = mri_rf_pulse_sim.ui_prop.list(parent=self, name="window_list", items=window_list, value=self.label_none);

            if     isfield(args, 'list' )
                self.list       = args.list;
            elseif isfield(args, 'value')
                self.list.value = args.value;
            end

            if isfield(args, 'name'   ), self.name    = args.name   ; end
            if isfield(args, 'visible'), self.visible = args.visible; end
            if isfield(args, 'parent' ), self.parent  = args.parent ; end

            if self.list.value ~= self.label_none
                self.child = feval(sprintf('mri_rf_pulse_sim.backend.window.%s', self.list.value));
            end
        end % fcn

        function shape = getShape(self, time)
            if nargin < 2
                t = self.parent.time;
            else
                t = time;
            end

            if self.list.value == self.label_none
                shape = ones(size(t));
            else
                shape = self.child.getShape(t);
            end
        end % fcn

        function plot(self)
            self.child.plot();
        end % fcn

        function set(self, value)
            self.list.value = value;
            if self.list.value ~= self.label_none
                self.child = feval(sprintf('mri_rf_pulse_sim.backend.window.%s', self.list.value));
            end
        end % fcn

        function txt = summary(self)
            if isempty(self.name)
                txt = sprintf(     '%s',            self.list.value);
            else
                txt = sprintf('[%s] %s', self.name, self.list.value);
            end
        end % fcn

        function displayRep = compactRepresentationForSingleLine(self,displayConfiguration,width)
            displayRep = widthConstrainedDataRepresentation(self,displayConfiguration,width,...
                StringArray=self.repr,AllowTruncatedDisplayForScalar=true);
        end % fcn

    end % meths

end % class
