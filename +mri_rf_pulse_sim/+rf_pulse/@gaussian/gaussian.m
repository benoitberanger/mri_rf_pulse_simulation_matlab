classdef gaussian < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Gaussian pulse is typicaly used for fat saturation.
    % Here, frequency_offcet default value is the frequency shift of the fat (lipids) at 3T.
    % Select dB0 = +3.5ppm (440Hz at 3T) -> the slice will now be "centered", its the fat that will be excited, not water.
    %
    % With this implementation the excitation bandwith only depends on the pulse duration.
    %
    % Handbook of MRI Pulse Sequences // Matt A. Bernstein, Kevin F. King, Xiaohong Joe Zhou

    properties (GetAccess = public, SetAccess = public)
        flip_angle       mri_rf_pulse_sim.ui_prop.scalar                   % [deg] flip angle
        frequency_offcet mri_rf_pulse_sim.ui_prop.scalar                   % [Hz] frequency offcet
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]
        sigma                                                              % []
    end % props

    methods % no attribute for dependent properies
        function value = get.sigma    (self); value = self.duration/7.734; end
        function value = get.bandwidth(self); value = 0.3748/self.sigma  ; end
    end % meths

    methods (Access = public)

        % constructor
        function self = gaussian()
            self.flip_angle       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle'      , value= 90, unit='°' );
            self.frequency_offcet = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='frequency_offcet', value=440, unit='Hz');
            self.generate_gaussian();
        end % fcn

        function generate(self)
            self.generate_gaussian();
        end % fcn

        function generate_gaussian(self)

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());

            waveform = exp(-self.time.^2 / (2*self.sigma^2)); % base waveform
            waveform = waveform / trapz(self.time, waveform); % normalize integral
            waveform = waveform * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle

            self.B1 = waveform .* exp(1j * 2*pi*self.frequency_offcet * self.time); % add frequency offcet scaled waveform
            self.GZ  = ones(size(self.time)) * self.GZavg;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('rect : flip_angle=%d°  frequency_offcet=%gHz  bandwidth=%gHz',...
                self.flip_angle.get(), self.frequency_offcet.get(), self.bandwidth);
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.flip_angle self.frequency_offcet],...
                [0 0 1 1]...
                );
        end % fcn

    end % meths

end % class