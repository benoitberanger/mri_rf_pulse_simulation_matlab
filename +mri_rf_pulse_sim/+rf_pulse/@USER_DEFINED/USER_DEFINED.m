classdef USER_DEFINED < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % This class is used as "entry point" for the user so they can define a
    % pulse from scratch dynamically within the GUI

    properties(SetAccess = public, GetAccess = public)
        bw mri_rf_pulse_sim.ui_prop.scalar                                 % [Hz]
    end % props

    methods (Access = public)

        % constructor
        function self = USER_DEFINED()
            self.bw = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='bw', value=1000, unit='Hz');
            self.generate();
            self.n_points.value = 8;
            self.time      = linspace(0, self.duration.value, self.n_points.value);
            self.B1        = zeros(size(self.time));
            self.GZ        = zeros(size(self.time));
        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_USER_DEFINED_bandwidth();
        end % fcn

        function value = get_USER_DEFINED_bandwidth(self)
            value = self.bw.get();
        end % fcn

        function generate(self) %#ok<MANU>  #abstract
            % pass
        end % fcn

        function txt = summary(self) %#ok<MANU>  #abstract
            txt = '<USER_DEFINED>';
        end % fcn

        function init_specific_gui(self, container) %#ok<INUSD>  #abstract
            % pass
        end % fcn

        function notify_app_update_pulse(self,~)
            notify(self.app, 'update_pulse');
        end % fcn

    end % meths

end % class
