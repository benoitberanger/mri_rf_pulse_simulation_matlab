classdef rect < mri_rf_pulse_sim.backend.rf_pulse.duration_based

    properties (GetAccess = public, SetAccess = public)
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle
        gz         mri_rf_pulse_sim.ui_prop.scalar                         % [T/m] slice/slab selection gradient
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth       (1,1) double                                       % Hz
        slice_thickness (1,1) double                                       % [m]
    end % props

    methods % no attribute for dependent properies
        function value = get.bandwidth(self)
            value = 1 / self.duration;
        end% % fcn
        function value = get.slice_thickness(self)
            value = 2*pi * self.bandwidth / (self.gamma * self.Gz__max);
        end % fcn
    end % meths

    methods (Access = public)

        % constructor
        function self = rect()
            self.n_points.value = 32;
            self.duration.value = 5 * 1e-3;
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=90       , unit='°'              );
            self.gz         = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='gz'        , value=10 * 1e-3, unit='mT/m', scale=1e3);
            self.generate_rect();
        end % fcn

        function generate(self)
            self.generate_rect();
        end % fcn

        % generate time, AM, FM, GM
        function generate_rect(self)
            self.assert_nonempty_prop({'n_points', 'duration','flip_angle'})

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());

            self.amplitude_modulation = ones(size(self.time)); % base shape
            self.amplitude_modulation = self.amplitude_modulation / trapz(self.time, self.amplitude_modulation); % normalize integral
            self.amplitude_modulation = self.amplitude_modulation * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.frequency_modulation = zeros(size(self.time));
            self.gradient_modulation  = ones(size(self.time)) * self.gz;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('rect : flip_angle=%d°  gz=%gmT/m',...
                self.flip_angle.get(), self.gz.get());
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.flip_angle, self.gz],...
                [0 0 1 1]...
                );
        end % fcn

    end % meths

end % class
