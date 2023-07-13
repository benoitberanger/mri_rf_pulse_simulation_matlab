classdef (Abstract) abstract < mri_rf_pulse_sim.backend.base_class

    properties (GetAccess = public, SetAccess = public)
        name     (1,:) char
        rf_pulse
    end % props

    properties (GetAccess = public, SetAccess = public, Abstract)
        shape    (1,:) double                                              % shape of the window
    end % props

    methods
        function set.rf_pulse(self,value)
            assert(isa(value,'mri_rf_pulse_sim.backend.rf_pulse.abstract'))
            self.rf_pulse = value;
        end
    end
    
    methods (Access = public)

        function plot(self, container)

            if ~exist('container','var')
                container = figure('NumberTitle','off','Name',self.summary());
            end

            time = self.rf_pulse.time*1e3;

            a = axes(container);
            hold(a,'on');
            plot(a, time, self.shape, 'LineStyle','-', 'LineWidth',2)
            a.XLabel.String = 'time (ms)';
            plot(a, [time(1) time(end)], [0 0], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5])
            plot(a, [time(1) time(end)], [1 1], 'LineStyle',':', 'LineWidth',0.5, 'Color', [0.5 0.5 0.5])
            ylim(a, [0 1])
            axis(a,'tight')

        end % fcn

        function callback_update(self, ~, ~)
            self.notify_parent();
        end

    end % meths

    methods(Abstract)
        summary
    end

end % class
