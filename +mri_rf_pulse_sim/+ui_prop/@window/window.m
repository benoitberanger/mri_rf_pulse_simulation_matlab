classdef window < mri_rf_pulse_sim.backend.base_class

    properties(GetAccess = public, SetAccess = public, SetObservable, AbortSet)
        list          mri_rf_pulse_sim.ui_prop.list
        bool          mri_rf_pulse_sim.ui_prop.bool
        name    (1,:) char
        child
        visible (1,1) string {mustBeMember(visible,["on","off"])} = "on"

        fig           matlab.ui.Figure
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        repr
    end % props

    methods % no attribute for dependent properties
        function value = get.repr(self)
            value = self.summary();
        end
    end % methods

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
            self.list   = mri_rf_pulse_sim.ui_prop.list(parent=self, name="window_list", items=window_list, value=self.label_none);

            if     isfield(args, 'list' )
                self.list       = args.list;
            elseif isfield(args, 'value')
                self.list.value = args.value;
            end

            if isfield(args, 'name'   ), self.name    = args.name   ; end
            if isfield(args, 'visible'), self.visible = args.visible; end
            if isfield(args, 'parent' ), self.parent  = args.parent ; end

            self.bool = mri_rf_pulse_sim.ui_prop.bool(parent=self, name='Windowing', text='Windowing', value=~isempty(self.list.idx), visible=self.visible);

            self.populateChild();
        end % fcn

        function shape = getShape(self, time)
            if nargin < 2
                t = self.parent.time;
            else
                t = time;
            end

            if isempty(self.child)
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
            self.populateChild();
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

        function add_uicontrol(self, container, rect)
            if nargin < 3
                rect = [0 0 1 1];
            end
            self.bool.add_uicontrol(container, rect);
        end % fcn

        function callback_update(self, ~, ~)
            if self.bool.checkbox.Value

                if ishandle(self.fig)

                    handles = guidata(self.fig);
                    delete(handles.uipanel_plot.Children)
                    delete(handles.uipanel_settings.Children)
                    self.populateChild();
                    self.parent.generate();
                    self.child.init_gui(handles.uipanel_settings);
                    self.child.plot    (handles.uipanel_plot    );
                    self.notify_parent();

                else

                    self.set("hanning");
                    self.notify_parent();

                    fig_pos = mri_rf_pulse_sim.backend.gui.get_fig_pos   ();
                    fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();

                    % Create a figure
                    figHandle = figure( ...
                        'MenuBar'         , 'none'                   , ...
                        'Toolbar'         , 'none'                   , ...
                        'Name'            , 'Pulse window'           , ...
                        'NumberTitle'     , 'off'                    , ...
                        'Units'           , 'normalized'             , ...
                        'Position'        , fig_pos.window           , ...
                        'Color'           , fig_col.figureBG         , ...
                        'CloseRequestFcn' , @self.callback_cleanup   );

                    % Create GUI handles : pointers to access the graphic objects
                    handles               = guihandles(figHandle);
                    handles.fig           = figHandle;

                    handles.uipanel_plot = uipanel(figHandle,...
                        'Title','Plot',...
                        'Units','Normalized',...
                        'Position',[0 0 1 0.7],...
                        'BackgroundColor',fig_col.figureBG);

                    handles.uipanel_selection = uipanel(figHandle,...
                        'Title','Selection',...
                        'Units','Normalized',...
                        'Position',[0 0.7 0.4 0.3],...
                        'BackgroundColor',fig_col.figureBG);

                    handles.uipanel_settings = uipanel(figHandle,...
                        'Title','Settings',...
                        'Units','Normalized',...
                        'Position',[0.4 0.7 0.6 0.3],...
                        'BackgroundColor',fig_col.figureBG);

                    % IMPORTANT
                    guidata(figHandle,handles)
                    % After creating the figure, dont forget the line
                    % guidata(figHandle,handles) . It allows smart retrieve like
                    % handles=guidata(hObject)

                    self.fig = figHandle;

                    self.list.add_uicontrol(handles.uipanel_selection);
                    self.child.init_gui(handles.uipanel_settings);
                    self.child.plot    (handles.uipanel_plot    );

                end

            else

                self.callback_cleanup();

            end
        end % fcn

        function callback_cleanup(self,varargin)
            delete(self.fig);
            delete(self.list.listener__listbox)
            self.bool.setFalse();
            self.set(self.label_none);
            self.populateChild();
            self.notify_parent();
        end % fcn

    end % meths

    methods(Access=protected)

        function populateChild(self)
            if any( strcmp(self.list.value, [self.label_none, ""]) )
                self.child = [];
            else
                self.child = feval(sprintf('mri_rf_pulse_sim.backend.window.%s', self.list.value), rf_pulse=self.parent);
            end
        end % fcn

    end % meth

end % class
