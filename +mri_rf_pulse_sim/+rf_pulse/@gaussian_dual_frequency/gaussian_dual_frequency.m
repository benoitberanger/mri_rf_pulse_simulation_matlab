classdef gaussian_dual_frequency < mri_rf_pulse_sim.backend.rf_pulse.abstract

    properties (GetAccess = public, SetAccess = public)
        flip_angle         mri_rf_pulse_sim.ui_prop.scalar                 % [deg] flip angle
        frequency_offcet   mri_rf_pulse_sim.ui_prop.scalar                 % [Hz] frequency offcet
        spoiler_duration   mri_rf_pulse_sim.ui_prop.scalar                 % [s] spoiler gradient duration
        spoiler_amplitude  mri_rf_pulse_sim.ui_prop.scalar                 % [rad] spoiler gradient dephasing
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        sigma                                                              % []
        Ag                                                                 % [T] amplitude
    end % props

    methods % no attribute for dependent properties
        function value = get.sigma    (self); value = self.duration/7.734; end
        function value = get.Ag       (self)
            value = deg2rad(self.flip_angle.get()) / ...
                (self.gamma * self.sigma * sqrt(2*pi));
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = gaussian_dual_frequency()
            self.slice_thickness.set(Inf);
            self.flip_angle        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle'       , value=  90   , unit='°'               );
            self.frequency_offcet  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='frequency_offcet' , value=1000   , unit='Hz'              );
            self.spoiler_duration  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='spoiler_duration' , value=   0   , unit='ms'  , scale=1e3 );
            self.spoiler_amplitude = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='spoiler_amplitude', value=  10e-3, unit='mT/m', scale=1e3);
            self.generate_gaussian_dual_frequency();
        end % fcn

        function value = get_gaussian_dual_frequency_bandwidth(self)
            value = 0.3748/self.sigma;
        end % fcn

        function generate_gaussian_dual_frequency(self)
            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());
            self.B1   = self.Ag * exp(-self.time.^2/(2*self.sigma^2)) .* sin(2*pi*self.frequency_offcet*self.time) * 2;
            self.GZ   = ones(size(self.time)) * self.GZavg;

            if self.spoiler_duration > 0
                n_pts = round(self.n_points * self.spoiler_duration / self.duration);
                self.time = [self.time linspace(self.time(end), self.time(end)+self.spoiler_duration, n_pts)];
                self.B1   = [self.B1   zeros(1,n_pts)                       ];
                self.GZ   = [self.GZ    ones(1,n_pts)*self.spoiler_amplitude];
            end
        end % fcn

        function generate(self) % #abstract
            self.generate_gaussian_dual_frequency();
        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_gaussian_dual_frequency_bandwidth();
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  flip_angle=%s  frequency_offcet=%s  bandwidth=%gHz  spoiler_durationn=%s  spoiler_amplitude=%s',...
                mfilename, self.flip_angle.repr, self.frequency_offcet.repr, self.bandwidth, self.spoiler_duration.repr, self.spoiler_amplitude.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.flip_angle self.frequency_offcet self.spoiler_duration self.spoiler_amplitude],...
                [0 0 1 1]...
                );
        end % fcn

    end % meths

end % class
