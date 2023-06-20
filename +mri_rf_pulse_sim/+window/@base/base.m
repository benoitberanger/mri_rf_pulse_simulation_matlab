classdef base < mri_rf_pulse_sim.base_class

    properties (GetAccess = public, SetAccess = public)
        name     (1,:) char
        rf_pulse       mri_rf_pulse_sim.rf_pulse.base
    end % props

    methods (Access = public)

        function plot(self, container)

            if ~exist('container','var')
                container = figure('NumberTitle','off','Name',self.summary());
            end

            a = axes(container);
            plot(a, self.rf_pulse.time*1e3, self.shape, 'LineStyle','-', 'LineWidth',2)
            a.XLabel.String = 'time (ms)';

        end % fcn

        function callback_update(self, ~, ~)
            self.notify_parent();
        end

    end % meths

end % class
