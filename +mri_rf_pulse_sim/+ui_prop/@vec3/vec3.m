classdef vec3 < mri_rf_pulse_sim.backend.base_class

    properties(GetAccess = public, SetAccess = public, SetObservable, AbortSet)
        name   (1,:) char
        xyz    (1,3) double
        unit         char
        scale  (1,1) double {mustBeFinite} = 1
    end % props

    properties (GetAccess = public, SetAccess = public)
        edit         matlab.ui.control.UIControl
    end % props

    properties (GetAccess = public, SetAccess = public, Dependent)
        x (1,1) double
        y (1,1) double
        z (1,1) double
    end % props

    methods % no attribute for dependent properties
        function val = get.x(self)    , val = self.xyz(1)      ; end
        function val = get.y(self)    , val = self.xyz(2)      ; end
        function val = get.z(self)    , val = self.xyz(3)      ; end
        function       set.x(self,val),       self.xyz(1) = val; end
        function       set.y(self,val),       self.xyz(2) = val; end
        function       set.z(self,val),       self.xyz(3) = val; end
    end % meths

    methods (Access = public)

        % constructor
        function self = vec3(args)
            arguments
                args.name
                args.xyz
                args.unit
                args.scale
                args.parent
            end % args

            if length(fieldnames(args)) < 1
                return
            end

            assert(isfield(args,'name'),'name is required')
            assert(isfield(args, 'xyz'), 'xyz is required')
            self.name = args.name;
            self.xyz  = args.xyz;

            if isfield(args, 'unit'  ), self.unit   = args.unit  ; end
            if isfield(args, 'scale' ), self.scale  = args.scale ; end
            if isfield(args, 'parent'), self.parent = args.parent; end
        end % fcn

        function out = double(self)
            out = self.xyz;
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

        function out = get(self)
            out = self.xyz * self.scale;
        end % fcn
        function set(self, in)
            self.xyz = in;
        end % fcn

        function add_uicontrol(self,container,rect)

            if nargin < 3
                rect = [0 0 1 1];
            end

            pos_text = mri_rf_pulse_sim.backend.gui.compose_rect([0.0  0.0  0.3  1.0], rect);
            pos_edit = mri_rf_pulse_sim.backend.gui.compose_rect([0.3  0.0  0.7  1.0], rect);

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
                'String'          , num2str(self.xyz * self.scale) ,...
                'Units'           , 'normalized'                     ,...
                'BackgroundColor' , [1 1 1]                          ,...
                'Position'        , pos_edit                         ,...
                'Callback'        , @self.callback_update             ...
                );

            addlistener(self, 'xyz', 'PostSet', @self.postset_update);

        end % fcn

        function displayRep = compactRepresentationForSingleLine(self,displayConfiguration,width)
            txt = sprintf('[%g %g %g]', self.x, self.y, self.z);
            if self.scale ~= 1
                txt = sprintf('%s ([%g %g %g])', txt, self.x*self.scale, self.y*self.scale, self.z*self.scale);
            end
            if ~isempty(self.unit)
                txt = sprintf(' %s', txt, self.unit);
            end
            displayRep = widthConstrainedDataRepresentation(self,displayConfiguration,width,...
                StringArray=txt,AllowTruncatedDisplayForScalar=true);
        end % fcn

    end % meths

    methods(Access = protected)

        function callback_update(self, src, ~)
            prev_xyz = self.xyz;
            try
                self.xyz = str2num(src.String) / self.scale; %#ok<ST2NM>
            catch
                src.String = num2str(prev_xyz * self.scale);
            end
        end % fcn

        function postset_update(self, ~, ~)
            new_xyz          = self.xyz;
            self.edit.String = num2str(new_xyz * self.scale);

            self.notify_parent();
        end % fcn

    end % meths

end % class
