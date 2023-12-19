classdef USER_DEFINED < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % This class is used as "entry point" for the user so they can define a
    % pulse from scratch dynamically within the GUI

    properties (GetAccess = public, SetAccess = protected)
        bandwidth                                                          % Hz
    end % props

    methods % no attribute for dependent properties
        function value = get.bandwidth(self       ); value          = self.bandwidth; end
        function         set.bandwidth(self, value); self.bandwidth = value         ; end
    end % meths

    methods (Access = public)

        % constructor
        function self = USER_DEFINED()
            self.generate();
            self.n_points.value = 8;
            self.time      = linspace(0, self.duration.value, self.n_points.value);
            self.B1        = zeros(size(self.time));
            self.GZ        = zeros(size(self.time));
            self.bandwidth = 1000; % set to a default value
        end % fcn

        function generate(self)
            % pass
        end % fcn

        function txt = summary(self)
            txt = '<USER_DEFINED>';
        end % fcn

        function init_specific_gui(self, container)
            % pass
        end % fcn

        function notify_app_update_pulse(self,~)
            notify(self.app, 'update_pulse');
        end % fcn

    end % meths

end % class
