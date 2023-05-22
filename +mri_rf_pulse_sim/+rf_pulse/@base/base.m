classdef base < handle

    properties (GetAccess = public, SetAccess = public, SetObservable)

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

    properties (GetAccess = public, SetAccess = protected, Hidden)
        ui__n_points matlab.ui.control.UIControl                           % pointer to the GUI object
        ui__duration matlab.ui.control.UIControl                           % pointer to the GUI object
    end % props

    methods (Access = public)

        % plot the shape of the pulse : AM, FM, GM
        % it will be plotted in a new figure or a pre-opened figure/uipanel
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

    end % meths

    methods (Access = protected)

        function assert_nonempty_prop(self, prop_list)
            assert(ischar(prop_list) || iscellstr(prop_list)) %#ok<ISCLSTR>
            prop_list = cellstr(prop_list); % force cellstr
            for p = 1 : numel(prop_list)
                assert( ~isempty(self.(prop_list{p})), 'empty %s', prop_list{p} )
            end
        end % fcn

        % gui callback to propagate the fresh value to the underlying
        % object in the app
        function callback_update_value(self, src, ~)
            res = strsplit(src.Tag,'__');
            prop_name = res{2};
            prev_value = self.(prop_name);
            try
                self.(prop_name) = str2double(src.String) * src.UserData;
            catch
                src.String = num2str(prev_value * 1/src.UserData);
            end
        end % fcn

        % 'wrapper' to add several observable properties in the GUI
        function handles = add_synced_props(self, container, handles, list)
            n_props = size(list, 1);
            spacing = 1/n_props;

            for p = n_props : -1 : 1
                prop  = list{p,1};
                txt   = list{p,2};
                scale = list{p,3};

                handles.(sprintf('text_%s', prop)) = uicontrol(container,...
                    'Style','text',...
                    'String',txt,...
                    'Units','normalized',...
                    'BackgroundColor',handles.figureBGcolor,...
                    'Position',[0 (p-1)*spacing 0.3 spacing]);

                name = sprintf('edit__%s', prop);
                handles.(name) = uicontrol(container,...
                    'Tag',name,...
                    'Style','edit',...
                    'String',num2str(self.(prop) / scale),...
                    'Units','normalized',...
                    'BackgroundColor',handles.editBGcolor,...
                    'Position',[0.3 (p-1)*spacing 0.7 spacing],...
                    'Callback',@self.callback_update_value,...
                    'UserData',scale); % scaling factor GUI -> SI units
                self.(sprintf('ui__%s',prop)) = handles.(name);

                addlistener(self, prop, 'PostSet', @mri_rf_pulse_sim.rf_pulse.base.gui_prop_changed);
            end
        end % fcn

    end % meths

    methods (Access = {?mri_rf_pulse_sim.pulse_definition})

        function init_base_gui(self, container)
            handles = guidata(container);

            handles = self.add_synced_props(container, handles, ...
                {
                'duration'  'duration (ms) = '  1e-3
                'n_points'       'n_points = '  1
                });

            guidata(handles.fig, handles);
        end

    end % meths

    methods (Static, Access = protected)

        % This method is called when the property is Set. It can be
        % from the command line, from a script, from a function...
        % It triggers the re-generation of the pulse, and a GUI update.
        % It also happens when the value is modified in the GUI : this
        % is useless, but it's a neglictable overhead for the moment.
        function gui_prop_changed(metaProp, eventData)
            prop_name      = metaProp.Name;
            rf_pulse       = eventData.AffectedObject;
            new_value      = rf_pulse.(prop_name);
            gui_obj        = rf_pulse.(sprintf('ui__%s', prop_name));
            gui_obj.String = num2str(new_value * 1/gui_obj.UserData);
            handles        = guidata(gui_obj);
            rf_pulse.generate();
            rf_pulse.plot(handles.uipanel_plot);
        end % fcn

    end % meths

end % class
