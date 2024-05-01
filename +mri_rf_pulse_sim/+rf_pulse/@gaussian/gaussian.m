classdef gaussian < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Gaussian pulse is typically used for fat saturation.
    % Here, frequency_offcet default value is the frequency shift of the fat (lipids) at 3T.
    % Select dB0 = +3.5ppm (440Hz at 3T) -> the slice will now be "centered", its the fat that will be excited, not water.
    %
    % With this implementation the excitation bandwidth only depends on the pulse duration.
    %
    % Handbook of MRI Pulse Sequences // Matt A. Bernstein, Kevin F. King, Xiaohong Joe Zhou

    properties (GetAccess = public, SetAccess = public)
        flip_angle       mri_rf_pulse_sim.ui_prop.scalar                   % [deg] flip angle
        frequency_offcet mri_rf_pulse_sim.ui_prop.scalar                   % [Hz] frequency offcet
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
        sigma                                                              % []
        Ag                                                                 % [T] amplitude
    end % props

    methods % no attribute for dependent properties
        function value = get.sigma    (self); value = self.duration/7.734; end
        function value = get.bandwidth(self); value = 0.3748/self.sigma  ; end
        function value = get.Ag       (self)
            value = deg2rad(self.flip_angle.get()) / ...
                (self.gamma * self.sigma * sqrt(2*pi));
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = gaussian()
            self.flip_angle       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle'      , value= 90, unit='°' );
            self.frequency_offcet = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='frequency_offcet', value=440, unit='Hz');
            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_gaussian();
        end % fcn

        function generate_gaussian(self)
            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());
            self.B1   = self.Ag * exp(-self.time.^2/(2*self.sigma^2)) .* exp(1j*2*pi*self.frequency_offcet*self.time);
            self.GZ   = ones(size(self.time)) * self.GZavg;
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  flip_angle=%s  frequency_offcet=%s  bandwidth=%gHz',...
                mfilename, self.flip_angle.repr, self.frequency_offcet.repr, self.bandwidth);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.flip_angle self.frequency_offcet],...
                [0 0 1 1]...
                );
        end % fcn

    end % meths

end % class
