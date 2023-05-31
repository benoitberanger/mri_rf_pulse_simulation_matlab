classdef simulation_parameters < mri_rf_pulse_sim.base_class

    properties(GetAccess = public, SetAccess = public, SetObservable, AbortSet)
        dZ  mri_rf_pulse_sim.ui_prop.range                                 % [m] slice (spin) position
        dB0 mri_rf_pulse_sim.ui_prop.range                                 % [ppm] off-resonance vector

        auto_simplot (1,1) logical = true                                  % state of the GUI checkbox
    end % props

    properties (GetAccess = public, SetAccess = protected, Hidden)
        ui__auto_simplot matlab.ui.control.UIControl                       % pointer to the GUI object
    end % props

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)
        fig matlab.ui.Figure
    end % props

    methods (Access = public)

        function self = simulation_parameters(varargin)

            self.dZ         = mri_rf_pulse_sim.ui_prop.range('dZ' , linspace(-10,10,201)/1e3, 1e3);
            self.dZ .parent = self;
            self.dB0        = mri_rf_pulse_sim.ui_prop.range('dB0', linspace(0,0,1));
            self.dB0.parent = self;

            if nargin < 1
                return
            end

            action = varargin{1};
            switch action
                case 'open_gui'
                    if nargin > 1
                        self.app = varargin{2};
                    end
                    self.open_gui();
                otherwise
                    error('unknown action')
            end

        end % fcn

        function open_gui(self)

            % Create a figure
            figHandle = figure( ...
                'MenuBar'         , 'none'                   , ...
                'Toolbar'         , 'none'                   , ...
                'Name'            , 'Simulation parameters'  , ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'Pixels'                 , ...
                'Position'        , [500, 50, 300, 350]      , ...
                'CloseRequestFcn' , @self.callback_cleanup   );

            figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
            buttonBGcolor = figureBGcolor - 0.1;
            editBGcolor   = [1.0 1.0 1.0];

            % Create GUI handles : pointers to access the graphic objects
            handles               = guihandles(figHandle);
            handles.fig           = figHandle;
            handles.figureBGcolor = figureBGcolor;
            handles.buttonBGcolor = buttonBGcolor;
            handles.editBGcolor   = editBGcolor  ;

            handles.uipanel_dB0 = uipanel(figHandle,...
                'Title','dB0 [ppm] : off-resonance',...
                'Units','Normalized',...
                'Position',[0 0 1 0.2],...
                'BackgroundColor',figureBGcolor);

            handles.uipanel_dZ = uipanel(figHandle,...
                'Title','dZ [mm] : slice (spin) position',...
                'Units','Normalized',...
                'Position',[0 0.2 1 0.2],...
                'BackgroundColor',figureBGcolor);

            self.dZ .add_uicontrol_setup(handles.uipanel_dZ )
            self.dB0.add_uicontrol_setup(handles.uipanel_dB0)

            handles.uipanel_controls = uipanel(figHandle,...
                'Title','Controls',...
                'Units','Normalized',...
                'Position',[0 0.4 1 0.6],...
                'BackgroundColor',figureBGcolor);

            handles.checkbox_auto_simplot = uicontrol(handles.uipanel_controls,...
                'Style','checkbox',...,
                'BackgroundColor',handles.figureBGcolor,...
                'Value',true,...
                'String','auto sim+plot',...
                'Units','normalized',...
                'Position',[0 0.9 0.5 0.1],...
                'Callback',@self.callback_auto_simplot);
            self.ui__auto_simplot = handles.checkbox_auto_simplot;
            addlistener(self, 'auto_simplot', 'PostSet', @self.gui_prop_changed);

            % IMPORTANT
            guidata(figHandle,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            self.fig = figHandle;

            % initialize with default values

        end % fcn

    end % meths

    methods(Access = protected)

        function callback_auto_simplot(self, src, ~)
            self.auto_simplot = src.Value;
            self.app.listener__update_setup .Enabled = self.auto_simplot;
            self.app.listener__update_select.Enabled = self.auto_simplot;
        end % fcn

        function gui_prop_changed(self, ~, ~)
            if self.app.simulation_parameters.auto_simplot
                self.app.simplot();
            end
        end % fcn

        function callback_cleanup(self,varargin)
            notify(self.app,'cleanup')
        end

    end % meths

end % class
