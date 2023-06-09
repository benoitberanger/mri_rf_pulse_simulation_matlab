classdef simulation_parameters < mri_rf_pulse_sim.backend.base_class

    properties(GetAccess = public, SetAccess = public)
        dZ  mri_rf_pulse_sim.ui_prop.range                                 % [m] slice (spin) position
        dB0 mri_rf_pulse_sim.ui_prop.range                                 % [ppm] off-resonance vector
        B0  mri_rf_pulse_sim.ui_prop.scalar                                % [T] static magnetic field strength

        auto_simplot mri_rf_pulse_sim.ui_prop.bool                         % state of the GUI checkbox
    end % props

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)
        fig matlab.ui.Figure
    end % props

    methods (Access = public)

        function self = simulation_parameters(varargin)

            self.dZ  = mri_rf_pulse_sim.ui_prop.range (parent=self, name='dZ' , vect=linspace(-010,010,201)/1e3, scale=1e3);
            self.dB0 = mri_rf_pulse_sim.ui_prop.range (parent=self, name='dB0', vect=linspace(-100,100,201)/1e6, scale=1e6);
            self.B0  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='B0' , value=2.89, unit='T');

            self.auto_simplot = mri_rf_pulse_sim.ui_prop.bool(parent=self, name='auto_simplot', text='auto_simplot', value=true);

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

            fig_pos = mri_rf_pulse_sim.backend.gui.get_fig_pos();

            % Create a figure
            figHandle = figure( ...
                'MenuBar'         , 'none'                   , ...
                'Toolbar'         , 'none'                   , ...
                'Name'            , 'Simulation parameters'  , ...
                'NumberTitle'     , 'off'                    , ...
                'Units'           , 'normalized'             , ...
                'Position'        , fig_pos.(mfilename)      , ...
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
                'Position',[0 0 1 0.3],...
                'BackgroundColor',figureBGcolor);

            handles.uipanel_dZ = uipanel(figHandle,...
                'Title','dZ [mm] : slice (spin) position',...
                'Units','Normalized',...
                'Position',[0 0.3 1 0.3],...
                'BackgroundColor',figureBGcolor);

            self.dZ .add_uicontrol_setup(handles.uipanel_dZ )
            self.dB0.add_uicontrol_setup(handles.uipanel_dB0)

            handles.uipanel_controls = uipanel(figHandle,...
                'Title','Controls',...
                'Units','Normalized',...
                'Position',[0 0.7 1 0.3],...
                'BackgroundColor',figureBGcolor);

            self.auto_simplot.add_uicontrol(handles.uipanel_controls,[0.0 0.5 0.2 0.5])

            handles.pushbutton_simplot = uicontrol(handles.uipanel_controls, ...
                'Style', 'pushbutton', ...
                'String', 'simulate + plot', ...
                'Units','Normalized',...
                'Position',[0.0 0.0 0.3 0.5],...
                'BackgroundColor',buttonBGcolor,...
                'Callback',@self.callback_simplot);

            self.B0.add_uicontrol(handles.uipanel_controls, [0.5 0 0.5 1])
            
            % IMPORTANT
            guidata(figHandle,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            self.fig = figHandle;

            % initialize with default values

        end % fcn

        function callback_update(self, ~, ~)
            if self.auto_simplot.get()
                self.app.simplot();
            end
        end % fcn

    end % meths

    methods(Access = protected)

        function callback_simplot(self,~,~)
            self.app.simplot();
        end

        function callback_cleanup(self,varargin)
            delete(self.fig)
            notify(self.app,'cleanup')
        end

    end % meths

end % class
