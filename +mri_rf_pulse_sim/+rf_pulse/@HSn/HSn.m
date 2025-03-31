classdef HSn < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Hyperbolic Secant of order `n`, as implmented in **Siemens** scanners

    properties (GetAccess = public, SetAccess = public)
        n          mri_rf_pulse_sim.ui_prop.scalar                         % [] power factor of the magnitude waveform
        R          mri_rf_pulse_sim.ui_prop.scalar                         % [] R = TimeBandWidthProduct (TBWP), it's the quality factor
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [°] Flip angle as defined in Siemens : scaled by a 1ms 180° RECT.
        b1cutoff   mri_rf_pulse_sim.ui_prop.scalar                         % [] RF waveform cutoff, in percentage (%)
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        beta                                                               % [rad/s]
    end % props

    methods % no attribute for dependent properties
        function value = get.beta(self); value = asech(self.b1cutoff.get()); end
    end % meths

    methods (Access = public)

        % constructor
        function self = HSn()
            self.n          = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n'         , value= 4                            );
            self.R          = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='R'         , value= 20                           );
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=300                , unit='°' );
            self.b1cutoff   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='b1cutoff'  , value=  0.064, scale=1e2 , unit='%'  );
            self.duration.set(10.24e-3);
            self.slice_thickness.set(Inf);
            self.generate_HSn();
        end % fcn

        function generate(self) % #abstract
            self.generate_HSn();
        end % fcn

        function generate_HSn(self)

            % --- prepare pulse waveform ---

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points);

            % reshape time so the magnitude waveform only depends on the cutoff
            T = (2*self.time / self.duration);

            % base waveforms
            magnitude =                     sech(self.beta * T.^self.n)    ;
            freq      = cumtrapz(self.time, sech(self.beta * T.^self.n).^2);

            % get phase from freq
            freq      = freq - mean(freq);       % center
            freq      = freq / max(freq);        % normalize
            freq      = freq* self.bandwidth*pi; % scale
            phase     = self.freq2phase(freq);

            % final pulse shape (before magnitude scaling)
            self.B1 = magnitude .* exp(1j * phase);
            self.GZ = ones(size(self.time)) * self.GZavg;

            % --- prepare scaling factor using Siemens `Vref` style ---

            % the reference pulse for scaling is a RECT of 1ms and 180°
            ref_duration = 0.001;
            ref_FA = 180;
            rect = mri_rf_pulse_sim.rf_pulse.rect();
            rect.gamma = self.gamma; % make sure to use the same nucleus
            rect.duration.set(ref_duration);
            rect.flip_angle.set(ref_FA);
            rect.generate();
            ref_B1 = max(rect.mag);

            hsn_real = real(self.B1);
            hsn_imag = imag(self.B1);
            hsn_real_integral = trapz(self.time, hsn_real);
            hsn_imag_integral = trapz(self.time, hsn_imag);
            hsn_amplitude_integral = sqrt( hsn_real_integral^2 + hsn_imag_integral^2 );

            % --- final scaling ---

            self.B1 = self.B1 * ref_B1 * (self.duration/hsn_amplitude_integral) * (self.flip_angle/ref_FA) * (ref_duration/self.duration);

        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_hs_bandwidth();
        end % fcn

        function value = get_hs_bandwidth(self)
            value = self.R / self.duration;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('[%s] {HS%d_R%d} : n=%s R=%s  FA=%s  cutoff=%s', ...
                mfilename, self.n.value, self.R.value, ...
                self.n.repr, self.R.repr, self.flip_angle.repr, self.b1cutoff.repr);
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n, self.R, self.flip_angle, self.b1cutoff]...
                );
        end % fcn

    end % meths

end % class
