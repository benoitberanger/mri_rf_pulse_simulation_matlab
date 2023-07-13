classdef (Abstract) abstract < mri_rf_pulse_sim.backend.base_class

    properties (GetAccess = public, SetAccess = public)
        n_points mri_rf_pulse_sim.ui_prop.scalar                           % []  number of points defining the pulse

        time                  (1,:) double                                 % [s] time vector
        amplitude_modulation  (1,:) double                                 % [T]
        frequency_modulation  (1,:) double                                 % [Hz]
        gradient_modulation   (1,:) double                                 % [T/m]

        gamma                 (1,1) double {mustBePositive} = mri_rf_pulse_sim.get_gamma('1H') % [rad/T/s] gyromagnetic ration
    end % props

    properties (GetAccess = public, SetAccess = protected)
        B1__max               (1,1) double                                 % [T]   max value of amplitude_modulation(t)
        Gz__max               (1,1) double                                 % [T/m] max value of  gradient_modulation(t)
    end % props

    methods % no attribute for dependent properies
        function value = get.B1__max(self)
            value = max(self.amplitude_modulation);
        end % fcn
        function value = get.Gz__max(self)
            value = max(self.gradient_modulation);
        end % fcn
    end % meths

    methods (Access = public)

        % constructor
        function self = abstract(varargin)
            self.n_points = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_points', value=256);
        end

        % plot the shape of the pulse : AM, FM, GM
        % it will be plotted in a new figure or a pre-opened figure/uipanel
        function plot(self, container)
            self.assert_nonempty_prop({'time', 'amplitude_modulation', 'frequency_modulation', 'gradient_modulation'})

            if ~exist('container','var')
                container = figure('NumberTitle','off','Name',self.summary());
            end

            a(1) = subplot(6,1,[1 2],'Parent',container);
            hold(a(1), 'on')
            plot(a(1), self.time*1e3, self.amplitude_modulation*1e6, 'LineStyle','-', 'LineWidth',2)
            a(1).XTickLabel = {};
            a(1).YLabel.String = 'a.m. (µT)';
            plot(a(1), [self.time(1) self.time(end)]*1e3, [0 0], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5])
            axis(a(1),'tight')

            a(2) = subplot(6,1,[3 4],'Parent',container);
            hold(a(2), 'on')
            plot(a(2), self.time*1e3, self.frequency_modulation, 'LineStyle','-', 'LineWidth',2)
            a(2).XTickLabel = {};
            a(2).YLabel.String = 'f.m. (Hz)';
            plot(a(2), [self.time(1) self.time(end)]*1e3, [0 0], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5])
            axis(a(2),'tight')

            a(3) = subplot(6,1,[5 6],'Parent',container);
            hold(a(3), 'on')
            plot(a(3), self.time*1e3, self.gradient_modulation*1e3, 'LineStyle','-', 'LineWidth',2)
            a(3).XLabel.String = 'time (ms)';
            a(3).YLabel.String = 'g.m. (mT/m)';
            plot(a(3), [self.time(1) self.time(end)]*1e3, [0 0], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5])
            axis(a(3),'tight')
        end

        function callback_update(self, ~, ~)
            self.notify_parent();
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

    methods (Abstract)

        summary
        init_base_gui

    end % meths

end % class
