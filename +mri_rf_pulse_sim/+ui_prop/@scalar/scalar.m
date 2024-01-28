classdef scalar < mri_rf_pulse_sim.backend.base_class

    properties(GetAccess = public, SetAccess = public, SetObservable, AbortSet)
        name   (1,:) char
        value  (1,1) double
        unit         char
        scale  (1,1) double {mustBeFinite} = 1
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        repr
    end % props

    methods % no attribute for dependent properties
        function value = get.repr(self)
            value = sprintf('%g', self.value);
            if     self.scale ~= 1 && ~isempty(self.unit)
                value = sprintf('%s(%g%s)', value, self.value*self.scale, self.unit);
            elseif self.scale == 1 && ~isempty(self.unit)
                value = sprintf('%s%s', value,  self.unit);
            elseif self.scale ~= 1 &&  isempty(self.unit)
                value = sprintf('%s(%g)', value, self.value*self.scale);
                % elseif self.scale == 1 &&  isempty(self.unit) % just pass this one
            end
        end
    end % methods

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

        function out = power(LEFT,RIGHT)
            out = double(LEFT) .^ double(RIGHT);
        end % fcn

        function out = getRaw(self)
            out = self.value;
        end % fcn
        function out = getScaled(self)
            out = self.value * self.scale;
        end % fcn
        function out = get(self)
            out = self.getRaw();
        end % fcn

        function setRaw(self, in)
            self.value = in;
        end % fcn
        function setScaled(self, in)
            self.value = in * self.scale;
        end % fcn
        function set(self, in)
            self.setRaw(in);
        end % fcn

        function add_uicontrol(self,container,rect)

            if nargin < 3
                rect = [0 0 1 1];
            end

            pos_text = mri_rf_pulse_sim.backend.gui.compose_rect([0.0  0.0  0.5  1.0], rect);
            pos_edit = mri_rf_pulse_sim.backend.gui.compose_rect([0.5  0.0  0.5  1.0], rect);

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
            displayRep = widthConstrainedDataRepresentation(self,displayConfiguration,width,...
                StringArray=self.repr,AllowTruncatedDisplayForScalar=true);
        end % fcn

    end % meths

    methods (Static)

        function add_uicontrol_multi_scalar(container,scalars, rect)
            if nargin < 3
                rect = [0 0 1 1];
            end

            scalars = fliplr(scalars);
            spacing = 1/numel(scalars);
            for s = 1 : length(scalars)
                pos = mri_rf_pulse_sim.backend.gui.compose_rect([0 (s-1)*spacing 1 spacing],rect);
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
