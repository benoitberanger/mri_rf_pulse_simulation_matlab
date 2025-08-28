classdef simulation_parameters < mri_rf_pulse_sim.backend.base_class

    properties(GetAccess = public, SetAccess = public)
        dZ              mri_rf_pulse_sim.ui_prop.range                     % [m] slice (spin) position
        dB0             mri_rf_pulse_sim.ui_prop.range                     % [ppm] off-resonance vector
        B0              mri_rf_pulse_sim.ui_prop.scalar                    % [T] static magnetic field strength
        T1              mri_rf_pulse_sim.ui_prop.scalar                    % [s] T1 relaxtion coefficient : set to +Inf by default
        T2              mri_rf_pulse_sim.ui_prop.scalar                    % [s] T2 relaxtion coefficient : set to +Inf by default
        M0              mri_rf_pulse_sim.ui_prop.vec3                      % initial magnetization vector
        auto_simplot    mri_rf_pulse_sim.ui_prop.bool
        auto_disp_pulse mri_rf_pulse_sim.ui_prop.bool
    end % props

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)
        fig matlab.ui.Figure
    end % props

    methods (Access = public)

        function self = simulation_parameters(args)
            arguments
                args.action
                args.app
            end

            self.dZ  = mri_rf_pulse_sim.ui_prop.range (parent=self, name='dZ' , vect=linspace(-010,010,201)*1e-3, scale=1e3, unit='mm' );
            self.dB0 = mri_rf_pulse_sim.ui_prop.range (parent=self, name='dB0', vect=linspace(-020,020,201)*1e-6, scale=1e6, unit='ppm');
            self.B0  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='B0' , value=3.00                                 , unit='T'  );
            self.T1  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='T1' , value=+Inf                      , scale=1e3, unit='ms' );
            self.T2  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='T2' , value=+Inf                      , scale=1e3, unit='ms' );
            self.M0  = mri_rf_pulse_sim.ui_prop.vec3  (parent=self, name='M0' , xyz=[0 0 1]'                                           );

            self.auto_simplot    = mri_rf_pulse_sim.ui_prop.bool(name='auto_simplot'   , text='auto_simplot'   , value=true);
            self.auto_disp_pulse = mri_rf_pulse_sim.ui_prop.bool(name='auto_disp_pulse', text='auto_disp_pulse', value=true);

            if length(fieldnames(args)) < 1
                return
            end

            if isfield(args, 'action'), action   = args.action; end
            if isfield(args, 'app'   ), self.app = args.app   ; end

            switch lower(action)
                case 'opengui'
                    self.opengui();
                case 'opengui_onefig'
                    self.opengui('onefig');
                otherwise
                    error('unknown action')
            end

        end % fcn

        function opengui(self, use_onefig)
            if nargin < 2
                use_onefig = false;
            end

            fig_pos = mri_rf_pulse_sim.backend.gui.get_fig_pos(use_onefig);
            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();

            if use_onefig

                container = uipanel(self.app.fig,...
                    'Title'           , 'Simulation parameters'  , ...
                    'Units'           , 'normalized'             , ...
                    'Position'        , fig_pos.(mfilename)      , ...
                    'BackgroundColor' , fig_col.figureBG         );

                handles = guidata(self.app.fig);

            else

                % Create a figure
                figHandle = figure( ...
                    'MenuBar'         , 'none'                   , ...
                    'Toolbar'         , 'none'                   , ...
                    'Name'            , 'Simulation parameters'  , ...
                    'NumberTitle'     , 'off'                    , ...
                    'Units'           , 'normalized'             , ...
                    'Position'        , fig_pos.(mfilename)      , ...
                    'CloseRequestFcn' , @self.callback_cleanup   , ...
                    'Color'           , fig_col.figureBG         );

                % Create GUI handles : pointers to access the graphic objects
                handles               = guihandles(figHandle);
                handles.fig           = figHandle;
                container             = figHandle;

            end

            % ALL PANELS
            handles.uipanel_range = uipanel(container,'Units','Normalized','Position',[0.00 0.25 0.60 0.75],'BackgroundColor',fig_col.figureBG);
            handles.uipanel_param = uipanel(container,'Units','Normalized','Position',[0.60 0.40 0.40 0.60],'BackgroundColor',fig_col.figureBG);
            handles.uipanel_contr = uipanel(container,'Units','Normalized','Position',[0.00 0.00 0.60 0.25],'BackgroundColor',fig_col.figureBG);
            handles.uipanel_pushb = uipanel(container,'Units','Normalized','Position',[0.60 0.00 0.40 0.40],'BackgroundColor',fig_col.figureBG);

            % range
            handles.uipanel_dZ  = uipanel(handles.uipanel_range,'Units','Normalized','Position',[0.00 0.50 1.00 0.50],'BackgroundColor',fig_col.figureBG,...
                'Title','dZ [mm] : slice (spin) position');
            handles.uipanel_dB0 = uipanel(handles.uipanel_range,'Units','Normalized','Position',[0.00 0.00 1.00 0.50],'BackgroundColor',fig_col.figureBG,...
                'Title','dB0 [ppm] : off-resonance');
            self.dZ .add_uicontrol_setup(handles.uipanel_dZ )
            self.dB0.add_uicontrol_setup(handles.uipanel_dB0)

            % param
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(handles.uipanel_param, ...
                [self.B0 self.T1 self.T2], ...
                [0.00 0.25 1.00 0.75])
            self.M0.add_uicontrol(handles.uipanel_param, [0.00 0.00 1.00 0.25])

            % controls
            self.auto_simplot   .add_uicontrol(handles.uipanel_contr,[0.00 0.50 0.50 0.50])
            self.auto_disp_pulse.add_uicontrol(handles.uipanel_contr,[0.00 0.00 0.50 0.50])

            % push buttons
            handles.pushbutton_simplot = uicontrol(handles.uipanel_pushb, ...
                'Style'          , 'pushbutton'           ,...
                'String'         , 'simulate + plot'      ,...
                'Units'          , 'Normalized'           ,...
                'Position'       , [0.10 0.10 0.80 0.80]  ,...
                'BackgroundColor', fig_col.buttonBG       ,...
                'Callback'       , @self.callback_simplot );

            % IMPORTANT
            guidata(container,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrieve like
            % handles=guidata(hObject)

            if use_onefig
                self.fig = self.app.fig;
            else
                self.fig = figHandle;
            end

            % initialize with default values

        end % fcn

        function callback_update(self, ~, ~)
            notify(self.app, 'update_setup');
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
