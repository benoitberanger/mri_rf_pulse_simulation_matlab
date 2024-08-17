classdef list < mri_rf_pulse_sim.backend.base_class

    properties(GetAccess = public, SetAccess = public, SetObservable, AbortSet)
        name   (1,:) char
        items  (:,1)
        value
    end % props

    properties(GetAccess = public, SetAccess = protected)
        type (1,:) char
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        idx
        repr
    end % props

    methods % no attribute for dependent properties
        function value = get.repr(self)
            value = sprintf('%s = %s', self.name, self.value);
        end
    end % methods

    properties (GetAccess = public, SetAccess = public)
        listbox           matlab.ui.control.UIControl
        listener__listbox event.listener
    end % props

    methods % no attributes for Dependent properties

        function value = get.idx(self)
            value = find(self.items == self.value);
        end % fcn

    end % meths

    methods (Access = public)

        % constructor
        function self = list(args)
            arguments
                args.name
                args.items
                args.value
                args.parent
            end % args

            if length(fieldnames(args)) < 1
                return
            end

            assert(isfield(args,  'name'),  'name is required')
            assert(isfield(args, 'items'), 'items is required')
            self.name  = args.name;

            if isnumeric(args.items)
                self.items = args.items;
                self.type = 'numeric';
            elseif isstring(args.items)
                self.items = args.items;
                self.type = 'text';
            elseif iscellstr(args.items)
                self.items = string(args.items);
                self.type = 'text';
            else
                error('items must be numeric, string, cellstr(will be converted to string)')
            end

            if isfield(args, 'parent'), self.parent = args.parent; end
            if isfield(args, 'value')
                self.value = args.value;
            else
                self.value = self.items{1};
            end
        end % fcn

        function out = get(self)
            out = self.value;
        end % fcn

        function add_uicontrol(self,container,rect)

            if nargin < 3
                rect = [0 0 1 1];
            end

            self.listbox = uicontrol(container,...
                'Style'           , 'listbox'             ,...
                'String'          , self.items            ,...
                'Value'           , self.idx              ,...
                'Units'           , 'normalized'          ,...
                'BackgroundColor' , [1 1 1]               ,...
                'Position'        , rect                  ,...
                'Tooltip'         , self.name             ,...
                'Callback'        , @self.callback_update  ...
                );

            self.listener__listbox = addlistener(self, 'value', 'PostSet', @self.postset_update);

        end % fcn

        function displayRep = compactRepresentationForSingleLine(self,displayConfiguration,width)
            displayRep = widthConstrainedDataRepresentation(self,displayConfiguration,width,...
                StringArray=self.repr,AllowTruncatedDisplayForScalar=true);
        end % fcn

    end % meths


    methods(Access = protected)

        function callback_update(self, src, ~)
            prev_idx = self.idx;
            if isstring(self.items) && any(self.items == src.String{src.Value})
                self.value = src.String{src.Value};
            elseif isnumeric(self.items) && any(self.items == str2double(src.String(src.Value,:)))
                self.value = str2double(src.String(src.Value));
            else
                src.Value = prev_idx;
            end
        end % fcn

        function postset_update(self, ~, ~)
            if ~ishandle(self.listbox), return, end
            self.listbox.Value = self.idx;
            self.notify_parent();
        end % fcn

    end % meths


end % class