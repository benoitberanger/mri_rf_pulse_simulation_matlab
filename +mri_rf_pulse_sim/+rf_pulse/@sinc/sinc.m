classdef sinc < mri_rf_pulse_sim.rf_pulse.base

    properties (GetAccess = public, SetAccess = public, SetObservable, AbortSet)

        n_lobs     mri_rf_pulse_sim.ui_prop.scalar                         % [] number of lobs, from 1 to +Inf
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle
        gz         mri_rf_pulse_sim.ui_prop.scalar                         % [T/m] slice/slab selection gradient

    end % props

    methods (Access = public)

        % constructor
        function self = sinc()
            self.n_lobs            = mri_rf_pulse_sim.ui_prop.scalar('n_lobs'    ,  7                    );
            self.flip_angle        = mri_rf_pulse_sim.ui_prop.scalar('flip_angle', 90       , '°'        );
            self.gz                = mri_rf_pulse_sim.ui_prop.scalar('gz'        , 10 * 1e-3, 'mT/m', 1e3);
            self.n_lobs    .parent = self;
            self.flip_angle.parent = self;
            self.gz        .parent = self;
            self.generate();
        end % fcn

        % generate time, AM, FM, GM
        function generate(self)
            self.assert_nonempty_prop({'n_points', 'duration', 'n_lobs'})

            self.time = linspace(-self.duration.value/2, +self.duration.value/2, self.n_points.value);

            lob_size = self.duration.value / (2*self.n_lobs.value);

            self.amplitude_modulation = sinc(self.time/lob_size); % base shape
            self.amplitude_modulation = self.amplitude_modulation / trapz(self.time, self.amplitude_modulation); % normalize integral
            self.amplitude_modulation = self.amplitude_modulation * deg2rad(self.flip_angle.value) / self.gamma; % scale integrale with flip angle
            self.frequency_modulation = zeros(size(self.time));
            self.gradient_modulation  = ones(size(self.time)) * self.gz.value;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('sinc : n_lobs=%d  flip_angle=%d°  gz=%gmT/m',...
                self.n_lobs.value, self.flip_angle.value, self.gz.value*self.gz.scale);
        end % fcn

    end % meths

    methods (Access = {?mri_rf_pulse_sim.pulse_definition})

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n_lobs, self.flip_angle, self.gz]...
                );
        end % fcn

    end % meths

end % class
