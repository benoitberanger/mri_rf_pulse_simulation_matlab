classdef base < handle

    properties (GetAccess = public, SetAccess = public)

        n_points              (1,1) double {mustBePositive, mustBeInteger} = 512                               % []  number of points defining the pulse
        duration              (1,1) double {mustBePositive}                =   5 * 1e-3                        % [s] pulse duration

        time                  (1,:) double                                                                     % [ms] time vector

        amplitude_modulation  (1,:) double                                                                     % [T]
        frequency_modulation  (1,:) double                                                                     % [Hz]
        gradient_modulation   (1,:) double                                                                     % [T/m]

        B0                    (1,1) double {mustBePositive}                =   2.89                            % [T] static magnetic field strength
        gamma                 (1,1) double {mustBePositive}                = mri_rf_pulse_sim.get_gamma('1H')  % [rad/T/s] gyromagnetic ration

    end % props

    properties (GetAccess = public, SetAccess = protected)

        B1__max                                                            % [T]   max value of amplitude_modulation(t)
        gz__max                                                            % [T/m] max value of  gradient_modulation(t)

    end % props

    methods (Access = public)

        function plot(self, container)
            self.assert_nonempty_prop({'time', 'amplitude_modulation', 'frequency_modulation', 'gradient_modulation'})
            
            if ~exist('container','var')
                container = figure('NumberTitle','off','Name',self.summary());
            end
            
            a(1) = subplot(6,1,[1 2],'Parent',container);
            plot(a(1), self.time*1e3, self.amplitude_modulation*1e6)
            a(1).XTickLabel = {};
            a(1).YLabel.String = 'a.m. (µT)';

            a(2) = subplot(6,1,[3 4],'Parent',container);
            plot(a(2), self.time*1e3, self.frequency_modulation)
            a(2).XTickLabel = {};
            a(2).YLabel.String = 'f.m. (Hz)';

            a(3) = subplot(6,1,[5 6],'Parent',container);
            plot(a(3), self.time*1e3, self.gradient_modulation*1e3)
            a(3).XLabel.String = 'time (ms)';
            a(3).YLabel.String = 'g.m. (mT/m)';
        end

        function init_base_gui(self, container)
            handles = guidata(container);

            handles.text_duration = uicontrol(container,...
                'Style','text',...
                'String','duration (ms) = ',...
                'Units','normalized',...
                'BackgroundColor',handles.figureBGcolor,...
                'Position',[0 0 0.3 0.5]);

            handles.text_n_points = uicontrol(container,...
                'Style','text',...
                'String','n_points = ',...
                'Units','normalized',...
                'BackgroundColor',handles.figureBGcolor,...
                'Position',[0 0.5 0.3 0.5]);

            handles.edit_duration = uicontrol(container,...
                'Style','edit',...
                'String',num2str(self.duration * 1e3),...
                'Units','normalized',...
                'BackgroundColor',handles.editBGcolor,...
                'Position',[0.3 0 0.7 0.5]);

            handles.edit_n_points = uicontrol(container,...
                'Style','edit',...
                'String',num2str(self.n_points),...
                'Units','normalized',...
                'BackgroundColor',handles.editBGcolor,...
                'Position',[0.3 0.5 0.7 0.5]);

            guidata(handles.fig, handles);
        end


    end % meths

    methods (Access = protected)

        function assert_nonempty_prop(self, prop_list)
            assert(ischar(prop_list) || iscellstr(prop_list)) %#ok<ISCLSTR>

            prop_list = cellstr(prop_list); % force cellstr

            for p = 1 : numel(prop_list)
                assert( ~isempty(self.(prop_list{p})), 'empty %s', prop_list{p} )
            end
        end % fcn

    end % meths

end % class
