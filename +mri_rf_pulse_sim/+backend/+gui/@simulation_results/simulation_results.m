classdef simulation_results < mri_rf_pulse_sim.backend.base_class

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)
        fig                   matlab.ui.Figure

        axes_Mxyz             matlab.graphics.axis.Axes
        line_M_x              matlab.graphics.chart.primitive.Line
        line_M_y              matlab.graphics.chart.primitive.Line
        line_M_para           matlab.graphics.chart.primitive.Line
        line_M_perp           matlab.graphics.chart.primitive.Line
        line_M_up             matlab.graphics.chart.primitive.Line
        line_M_mid            matlab.graphics.chart.primitive.Line
        line_M_down           matlab.graphics.chart.primitive.Line

        axes_Sphere           matlab.graphics.axis.Axes
        surface_Sphere        matlab.graphics.chart.primitive.Surface
        line3_Mxyz            matlab.graphics.chart.primitive.Line
        q3_Mxyz_end           matlab.graphics.chart.primitive.Quiver

        axes_SliceProfile     matlab.graphics.axis.Axes
        line_S_Mx             matlab.graphics.chart.primitive.Line
        line_S_My             matlab.graphics.chart.primitive.Line
        line_S_Mpara          matlab.graphics.chart.primitive.Line
        line_S_Mperp          matlab.graphics.chart.primitive.Line
        line_S_up             matlab.graphics.chart.primitive.Line
        line_S_mid            matlab.graphics.chart.primitive.Line
        line_S_down           matlab.graphics.chart.primitive.Line
        line_S_vert           matlab.graphics.chart.primitive.Line
        line_S_stL            matlab.graphics.chart.primitive.Line
        line_S_stR            matlab.graphics.chart.primitive.Line

        axes_ChemicalShiftPPM matlab.graphics.axis.Axes
        line_C_Mx             matlab.graphics.chart.primitive.Line
        line_C_My             matlab.graphics.chart.primitive.Line
        line_C_Mpara          matlab.graphics.chart.primitive.Line
        line_C_Mperp          matlab.graphics.chart.primitive.Line
        line_C_up             matlab.graphics.chart.primitive.Line
        line_C_mid            matlab.graphics.chart.primitive.Line
        line_C_down           matlab.graphics.chart.primitive.Line
        line_C_vert           matlab.graphics.chart.primitive.Line
        line_C_bwL            matlab.graphics.chart.primitive.Line
        line_C_bwR            matlab.graphics.chart.primitive.Line
        axes_ChemicalShiftHz  matlab.graphics.axis.Axes

    end % props

    methods (Access = public)

        function self = simulation_results(args)
            arguments
                args.action
                args.app
            end

            if length(fieldnames(args)) < 1
                return
            else
                if isfield(args, 'action'), action   = args.action; end
                if isfield(args, 'app'   ), self.app = args.app   ; end
            end

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

            % x + y = perp
            % z     = para

            color      = struct;
            color.x    = [230 030 030]/255;
            color.y    = [030 170 230]/255;
            color.para = [030 230 030]/255;
            color.perp = [230 030 210]/255;
            color.ref  = [150 150 150]/255;
            color.vert = [150 150 150]/255;
            color.st   = [200 200 200]/255;
            color.bw   = color.st;

            linestyle = struct;
            linestyle.x    = ':';
            linestyle.y    = ':';
            linestyle.para = '-';
            linestyle.perp = '-';
            linestyle.ref  = ':';
            linestyle.vert = '-';
            linestyle.st   = '-';
            linestyle.bw   = linestyle.st;

            linewidth = struct;
            linewidth.x    = 1.0;
            linewidth.y    = 1.0;
            linewidth.para = 2.0;
            linewidth.perp = 2.0;
            linewidth.ref  = 0.5;
            linewidth.vert = 1.0;
            linewidth.st   = 0.5;
            linewidth.bw   = linewidth.st;

            fig_pos = mri_rf_pulse_sim.backend.gui.get_fig_pos(use_onefig);
            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();

            if use_onefig

                container = uipanel(self.app.fig,...
                    'Title'           , 'Simulation results'     , ...
                    'Units'           , 'normalized'             , ...
                    'Position'        , fig_pos.(mfilename)      , ...
                    'BackgroundColor' , fig_col.figureBG         );

                handles = guidata(self.app.fig);

            else

                % Create a figure
                figHandle = figure( ...
                    'MenuBar'         , 'none'                   , ...
                    'Toolbar'         , 'none'                   , ...
                    'Name'            , 'Simulation results'     , ...
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

            %--------------------------------------------------------------
            % Range selection

            handles.uipanel_dZ = uipanel(container,...
                'Title','Selection',...
                'Units','Normalized',...
                'Position',[0 0.95 0.70 0.05],...
                'BackgroundColor',fig_col.figureBG);

            handles.uipanel_dB0 = uipanel(container,...
                'Title','Selection',...
                'Units','Normalized',...
                'Position',[0 0.90 0.70 0.05],...
                'BackgroundColor',fig_col.figureBG);

            dZ  = self.app.simulation_parameters.dZ ;
            dB0 = self.app.simulation_parameters.dB0;
            dZ. add_uicontrol_select(handles.uipanel_dZ );
            dB0.add_uicontrol_select(handles.uipanel_dB0)
            dZ .app = self.app;
            dB0.app = self.app;

            %--------------------------------------------------------------
            % FFT appriximation
            uicontrol(container,...
                'String','FFT approx Perp',...
                'Units','Normalized',...
                'Position',[0.75 0.95 0.20 0.05],...
                'BackgroundColor',fig_col.buttonBG,...
                'Callback', @self.callback_fft_approx_perp);
            uicontrol(container,...
                'String','FFT approx Para',...
                'Units','Normalized',...
                'Position',[0.75 0.90 0.20 0.05],...
                'BackgroundColor',fig_col.buttonBG,...
                'Callback', @self.callback_fft_approx_para);

            %--------------------------------------------------------------
            % Mxyz

            handles.uipanel_Mxyz = uipanel(container,...
                'Title','Mxyz(t)',...
                'Units','Normalized',...
                'Position',[0 0.6 1 0.3],...
                'BackgroundColor',fig_col.figureBG);

            time = self.app.pulse_definition.rf_pulse.time;

            handles.axes_Mxyz = axes(handles.uipanel_Mxyz,...
                'OuterPosition',[0 0 0.7 1]);
            self.axes_Mxyz = handles.axes_Mxyz;
            hold(handles.axes_Mxyz, 'on');
            self.line_M_x    = plot(handles.axes_Mxyz,                   0,     NaN, 'Color',color.x   , 'LineStyle',linestyle.x   , 'LineWidth',linewidth.x   );
            self.line_M_y    = plot(handles.axes_Mxyz,                   0,     NaN, 'Color',color.y   , 'LineStyle',linestyle.y   , 'LineWidth',linewidth.y   );
            self.line_M_para = plot(handles.axes_Mxyz,                   0,     NaN, 'Color',color.para, 'LineStyle',linestyle.para, 'LineWidth',linewidth.para);
            self.line_M_perp = plot(handles.axes_Mxyz,                   0,     NaN, 'Color',color.perp, 'LineStyle',linestyle.perp, 'LineWidth',linewidth.perp);
            self.line_M_up   = plot(handles.axes_Mxyz, [time(1) time(end)], [+1 +1], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_M_mid  = plot(handles.axes_Mxyz, [time(1) time(end)], [ 0  0], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_M_down = plot(handles.axes_Mxyz, [time(1) time(end)], [-1 -1], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            legend(handles.axes_Mxyz, {'M_x', 'M_y', 'M\mid\mid', 'M\perp'})
            axis(handles.axes_Mxyz, 'tight')
            xlabel(handles.axes_Mxyz, 'time (ms)');
            ylabel(handles.axes_Mxyz, 'M_x_y_z');
            ylim(handles.axes_Mxyz, [-1.1 +1.1])
            handles.axes_Mxyz.YLabel.Rotation = 0;
            handles.axes_Mxyz.YLabel.HorizontalAlignment = 'right';

            handles.axes_Sphere = axes(handles.uipanel_Mxyz,...
                'Position',[0.7 0 0.3 1]);
            self.axes_Sphere = handles.axes_Sphere;
            hold(handles.axes_Sphere, 'on')
            [X,Y,Z] = sphere(100);
            self.surface_Sphere = surf(handles.axes_Sphere, X, Y , Z, 'FaceAlpha',0.2, 'EdgeColor','none');
            colormap(self.axes_Sphere, white)
            self.line3_Mxyz = plot3(handles.axes_Sphere, 0,0,0, 'LineWidth', 2);
            self.q3_Mxyz_end = quiver3(handles.axes_Sphere,0,0,0,0,0,0,0,'Color',[000 000 000]/255,'LineWidth',2);
            axis(handles.axes_Sphere, 'off')
            rotate3d(handles.axes_Sphere, 'on')
            axis(handles.axes_Sphere, 'vis3d')
            view(handles.axes_Sphere,[1 1 1])
            quiver3(handles.axes_Sphere,0,0,0,1,0,0,0,'Color',color.x   )
            quiver3(handles.axes_Sphere,0,0,0,0,1,0,0,'Color',color.y   )
            quiver3(handles.axes_Sphere,0,0,0,0,0,1,0,'Color',color.para)

            %--------------------------------------------------------------
            % SliceProfile
            handles.uipanel_SliceProfile = uipanel(container,...
                'Title','SliceProfile',...
                'Units','Normalized',...
                'Position',[0 0.3 1 0.3],...
                'BackgroundColor',fig_col.figureBG);

            handles.axes_SliceProfile = axes(handles.uipanel_SliceProfile, 'Units','normalized', 'OuterPosition',[0.0 0.0 1.05 1.0]);
            self.axes_SliceProfile = handles.axes_SliceProfile;
            hold(handles.axes_SliceProfile, 'on')

            self.line_S_Mx    = plot(handles.axes_SliceProfile,                   0,         NaN, 'Color',color.x   , 'LineStyle',linestyle.x   , 'LineWidth',linewidth.x   );
            self.line_S_My    = plot(handles.axes_SliceProfile,                   0,         NaN, 'Color',color.y   , 'LineStyle',linestyle.y   , 'LineWidth',linewidth.y   );
            self.line_S_Mpara = plot(handles.axes_SliceProfile,                   0,         NaN, 'Color',color.para, 'LineStyle',linestyle.para, 'LineWidth',linewidth.para);
            self.line_S_Mperp = plot(handles.axes_SliceProfile,                   0,         NaN, 'Color',color.perp, 'LineStyle',linestyle.perp, 'LineWidth',linewidth.perp);
            self.line_S_up    = plot(handles.axes_SliceProfile, [time(1) time(end)], [+1   +1  ], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_S_mid   = plot(handles.axes_SliceProfile, [time(1) time(end)], [ 0    0  ], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_S_down  = plot(handles.axes_SliceProfile, [time(1) time(end)], [-1   -1  ], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_S_vert  = plot(handles.axes_SliceProfile, [0       0        ], [-1.2 +1.2], 'Color',color.vert, 'LineStyle',linestyle.vert, 'LineWidth',linewidth.vert);
            self.line_S_stL   = plot(handles.axes_SliceProfile, [NaN     NaN      ], [-1.2 +1.2], 'Color',color.st  , 'LineStyle',linestyle.st  , 'LineWidth',linewidth.st  );
            self.line_S_stR   = plot(handles.axes_SliceProfile, [NaN     NaN      ], [-1.2 +1.2], 'Color',color.st  , 'LineStyle',linestyle.st  , 'LineWidth',linewidth.st  );
            legend(handles.axes_SliceProfile, {'M_x', 'M_y', 'M\mid\mid', 'M\perp'})
            xlabel(handles.axes_SliceProfile, '\DeltaZ [mm]');
            ylabel(handles.axes_SliceProfile, 'final M_x_y_z');
            ylim  (handles.axes_SliceProfile, [-1.2 +1.2])
            handles.axes_SliceProfile.YLabel.Rotation = 0;
            handles.axes_SliceProfile.YLabel.HorizontalAlignment = 'right';

            %--------------------------------------------------------------
            % ChemicalShift
            handles.uipanel_ChemicalShift = uipanel(container,...
                'Title','ChemicalShift',...
                'Units','Normalized',...
                'Position',[0 0 1 0.3],...
                'BackgroundColor',fig_col.figureBG);
            % PPM
            handles.axes_ChemicalShiftPPM = axes(handles.uipanel_ChemicalShift, 'Units','normalized', 'OuterPosition',[0.0 0.0 1.05 0.9]);
            self.axes_ChemicalShiftPPM = handles.axes_ChemicalShiftPPM;
            hold(handles.axes_ChemicalShiftPPM, 'on')
            self.line_C_Mx    = plot(handles.axes_ChemicalShiftPPM,                   0,         NaN, 'Color',color.x   , 'LineStyle',linestyle.x   , 'LineWidth',linewidth.x   );
            self.line_C_My    = plot(handles.axes_ChemicalShiftPPM,                   0,         NaN, 'Color',color.y   , 'LineStyle',linestyle.y   , 'LineWidth',linewidth.y   );
            self.line_C_Mpara = plot(handles.axes_ChemicalShiftPPM,                   0,         NaN, 'Color',color.para, 'LineStyle',linestyle.para, 'LineWidth',linewidth.para);
            self.line_C_Mperp = plot(handles.axes_ChemicalShiftPPM,                   0,         NaN, 'Color',color.perp, 'LineStyle',linestyle.perp, 'LineWidth',linewidth.perp);
            self.line_C_up    = plot(handles.axes_ChemicalShiftPPM, [time(1) time(end)], [+1   +1  ], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_C_mid   = plot(handles.axes_ChemicalShiftPPM, [time(1) time(end)], [ 0    0  ], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_C_down  = plot(handles.axes_ChemicalShiftPPM, [time(1) time(end)], [-1   -1  ], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_C_vert  = plot(handles.axes_ChemicalShiftPPM, [0       0        ], [-1.2 +1.2], 'Color',color.vert, 'LineStyle',linestyle.vert, 'LineWidth',linewidth.vert);
            self.line_C_bwL   = plot(handles.axes_ChemicalShiftPPM, [NaN     NaN      ], [-1.2 +1.2], 'Color',color.bw  , 'LineStyle',linestyle.bw  , 'LineWidth',linewidth.bw  );
            self.line_C_bwR   = plot(handles.axes_ChemicalShiftPPM, [NaN     NaN      ], [-1.2 +1.2], 'Color',color.bw  , 'LineStyle',linestyle.bw  , 'LineWidth',linewidth.bw  );
            legend(handles.axes_ChemicalShiftPPM, {'M_x', 'M_y', 'M\mid\mid', 'M\perp'})
            xlabel(handles.axes_ChemicalShiftPPM, '\DeltaB_0 [ppm]');
            ylabel(handles.axes_ChemicalShiftPPM, 'final M_x_y_z');
            ylim  (handles.axes_ChemicalShiftPPM, [-1.2 +1.2])
            handles.axes_ChemicalShiftPPM.YLabel.Rotation = 0;
            handles.axes_ChemicalShiftPPM.YLabel.HorizontalAlignment = 'right';
            % Hz
            handles.axes_ChemicalShiftHz = axes(handles.uipanel_ChemicalShift, 'Units','normalized', 'Position',handles.axes_ChemicalShiftPPM.Position, ...
                'XAxisLocation','top', 'YAxisLocation','right', 'Color','none', 'Box','off', 'YTick',[]);
            self.axes_ChemicalShiftHz = handles.axes_ChemicalShiftHz;
            xlabel(handles.axes_ChemicalShiftHz, 'Hz')

            % IMPORTANT
            guidata(container,handles)
            % After creating the figure, dont forget the line
            % guidata(figHandle,handles) . It allows smart retrive like
            % handles=guidata(hObject)

            if use_onefig
                self.fig = self.app.fig;
            else
                self.fig = figHandle;
            end

            % initialize with default values

        end % fcn

    end % meths

    methods(Access = protected)

        function callback_cleanup(self,varargin)
            delete(self.fig)
            notify(self.app,'cleanup')
        end

        function callback_fft_approx_para(self,varargin)
            self.app.bloch_solver.plotFFTApproxPara();
        end
        function callback_fft_approx_perp(self,varargin)
            self.app.bloch_solver.plotFFTApproxPerp();
        end

    end

end % class
