classdef simulation_results < mri_rf_pulse_sim.base_class

    properties(GetAccess = public, SetAccess = ?mri_rf_pulse_sim.app)
        M (:,:,:,:) double

        fig matlab.ui.Figure

        axes_Mxyz          matlab.graphics.axis.Axes
        line_M_x           matlab.graphics.chart.primitive.Line
        line_M_y           matlab.graphics.chart.primitive.Line
        line_M_para        matlab.graphics.chart.primitive.Line
        line_M_perp        matlab.graphics.chart.primitive.Line
        line_M_up          matlab.graphics.chart.primitive.Line
        line_M_mid         matlab.graphics.chart.primitive.Line
        line_M_down        matlab.graphics.chart.primitive.Line

        axes_Sphere        matlab.graphics.axis.Axes
        surface_Sphere     matlab.graphics.chart.primitive.Surface
        line3_Mxyz         matlab.graphics.chart.primitive.Line
        q3_Mxyz_end        matlab.graphics.chart.primitive.Quiver

        axes_SliceProfile  matlab.graphics.axis.Axes
        line_S_Mx          matlab.graphics.chart.primitive.Line
        line_S_My          matlab.graphics.chart.primitive.Line
        line_S_Mpara       matlab.graphics.chart.primitive.Line
        line_S_Mperp       matlab.graphics.chart.primitive.Line
        line_S_up          matlab.graphics.chart.primitive.Line
        line_S_mid         matlab.graphics.chart.primitive.Line
        line_S_down        matlab.graphics.chart.primitive.Line

        axes_ChemicalShift matlab.graphics.axis.Axes
        line_C_Mx          matlab.graphics.chart.primitive.Line
        line_C_My          matlab.graphics.chart.primitive.Line
        line_C_Mpara       matlab.graphics.chart.primitive.Line
        line_C_Mperp       matlab.graphics.chart.primitive.Line
        line_C_up          matlab.graphics.chart.primitive.Line
        line_C_mid         matlab.graphics.chart.primitive.Line
        line_C_down        matlab.graphics.chart.primitive.Line
    end % props

    methods (Access = public)

        function self = simulation_results(varargin)
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

            % x + y = para
            % z     = perp

            color      = struct;
            color.x    = [230 030 030]/255;
            color.y    = [030 170 230]/255;
            color.para = [030 230 030]/255;
            color.perp = [230 030 210]/255;
            color.ref  = [150 150 150]/255;

            linestyle = struct;
            linestyle.x    = ':';
            linestyle.y    = ':';
            linestyle.para = '-';
            linestyle.perp = '-';
            linestyle.ref  = ':';

            linewidth = struct;
            linewidth.x    = 1.0;
            linewidth.y    = 1.0;
            linewidth.para = 2.0;
            linewidth.perp = 2.0;
            linewidth.ref  = 0.5;

            fig_pos = mri_rf_pulse_sim.ui_prop.get_fig_pos();

            % Create a figure
            figHandle = figure( ...
                'MenuBar'         , 'none'                   , ...
                'Toolbar'         , 'none'                   , ...
                'Name'            , 'Simulation results'     , ...
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

            %--------------------------------------------------------------
            % Range selection

            handles.uipanel_dZ = uipanel(figHandle,...
                'Title','Selection',...
                'Units','Normalized',...
                'Position',[0 0.95 1 0.05],...
                'BackgroundColor',figureBGcolor);

            handles.uipanel_dB0 = uipanel(figHandle,...
                'Title','Selection',...
                'Units','Normalized',...
                'Position',[0 0.90 1 0.05],...
                'BackgroundColor',figureBGcolor);

            dZ  = self.app.simulation_parameters.dZ ;
            dB0 = self.app.simulation_parameters.dB0;
            dZ. add_uicontrol_select(handles.uipanel_dZ );
            dB0.add_uicontrol_select(handles.uipanel_dB0)
            dZ .app = self.app;
            dB0.app = self.app;

            %--------------------------------------------------------------
            % Mxyz

            handles.uipanel_Mxyz = uipanel(figHandle,...
                'Title','Mxyz(t)',...
                'Units','Normalized',...
                'Position',[0 0.6 1 0.3],...
                'BackgroundColor',figureBGcolor);

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
            legend(handles.axes_Mxyz, {'Mx', 'My', 'M\mid\mid', 'M\perp'})
            axis(handles.axes_Mxyz, 'tight')
            xlabel(handles.axes_Mxyz, 'time (ms)');
            ylabel(handles.axes_Mxyz, 'Mxyz');
            ylim(handles.axes_Mxyz, [-1.1 +1.1])

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
            handles.uipanel_SliceProfile = uipanel(figHandle,...
                'Title','SliceProfile(dZ)',...
                'Units','Normalized',...
                'Position',[0 0.3 1 0.3],...
                'BackgroundColor',figureBGcolor);

            handles.axes_SliceProfile = axes(handles.uipanel_SliceProfile);
            self.axes_SliceProfile = handles.axes_SliceProfile;
            hold(handles.axes_SliceProfile, 'on')

            self.line_S_Mx    = plot(handles.axes_SliceProfile,                   0,     NaN, 'Color',color.x   , 'LineStyle',linestyle.x   , 'LineWidth',linewidth.x   );
            self.line_S_My    = plot(handles.axes_SliceProfile,                   0,     NaN, 'Color',color.y   , 'LineStyle',linestyle.y   , 'LineWidth',linewidth.y   );
            self.line_S_Mpara = plot(handles.axes_SliceProfile,                   0,     NaN, 'Color',color.para, 'LineStyle',linestyle.para, 'LineWidth',linewidth.para);
            self.line_S_Mperp = plot(handles.axes_SliceProfile,                   0,     NaN, 'Color',color.perp, 'LineStyle',linestyle.perp, 'LineWidth',linewidth.perp);
            self.line_S_up    = plot(handles.axes_SliceProfile, [time(1) time(end)], [+1 +1], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_S_mid   = plot(handles.axes_SliceProfile, [time(1) time(end)], [ 0  0], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_S_down  = plot(handles.axes_SliceProfile, [time(1) time(end)], [-1 -1], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            legend(handles.axes_SliceProfile, {'Mx', 'My', 'M\mid\mid', 'M\perp'})
            xlabel(handles.axes_SliceProfile, 'dZ [mm]');
            ylabel(handles.axes_SliceProfile, 'final Mxyz');
            ylim  (handles.axes_SliceProfile, [-1.2 +1.2])

            %--------------------------------------------------------------
            % ChemicalShift
            handles.uipanel_ChemicalShift = uipanel(figHandle,...
                'Title','ChemicalShift(ppm)',...
                'Units','Normalized',...
                'Position',[0 0 1 0.3],...
                'BackgroundColor',figureBGcolor);
            handles.axes_ChemicalShift = axes(handles.uipanel_ChemicalShift);
            self.axes_ChemicalShift = handles.axes_ChemicalShift;
            hold(handles.axes_ChemicalShift, 'on')
            self.line_C_Mx    = plot(handles.axes_ChemicalShift,                   0,     NaN, 'Color',color.x   , 'LineStyle',linestyle.x   , 'LineWidth',linewidth.x   );
            self.line_C_My    = plot(handles.axes_ChemicalShift,                   0,     NaN, 'Color',color.y   , 'LineStyle',linestyle.y   , 'LineWidth',linewidth.y   );
            self.line_C_Mpara = plot(handles.axes_ChemicalShift,                   0,     NaN, 'Color',color.para, 'LineStyle',linestyle.para, 'LineWidth',linewidth.para);
            self.line_C_Mperp = plot(handles.axes_ChemicalShift,                   0,     NaN, 'Color',color.perp, 'LineStyle',linestyle.perp, 'LineWidth',linewidth.perp);
            self.line_C_up    = plot(handles.axes_ChemicalShift, [time(1) time(end)], [+1 +1], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_C_mid   = plot(handles.axes_ChemicalShift, [time(1) time(end)], [ 0  0], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            self.line_C_down  = plot(handles.axes_ChemicalShift, [time(1) time(end)], [-1 -1], 'Color',color.ref , 'LineStyle',linestyle.ref , 'LineWidth',linewidth.ref );
            legend(handles.axes_ChemicalShift, {'Mx', 'My', 'M\mid\mid', 'M\perp'})
            xlabel(handles.axes_ChemicalShift, 'dB0 [ppm]');
            ylabel(handles.axes_ChemicalShift, 'final Mxyz');
            ylim  (handles.axes_ChemicalShift, [-1.2 +1.2])

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

        function callback_cleanup(self,varargin)
            delete(self.fig)
            notify(self.app,'cleanup')
        end

    end

end % class
