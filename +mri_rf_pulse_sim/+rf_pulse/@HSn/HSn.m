classdef HSn < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Hyperbolic Secant of order `n`, as implmented in **Siemens** scanners

    properties (GetAccess = public, SetAccess = public)
        n          mri_rf_pulse_sim.ui_prop.scalar                         % [] power factor of the magnitude waveform
        R          mri_rf_pulse_sim.ui_prop.scalar                         % [] R = TimeBandWidthProduct (TBWP), it's the quality factor
        Fsweep     mri_rf_pulse_sim.ui_prop.scalar                         % [] fsweep = frequency sweep, from -F to +F, it's the quality factor
        Siemens_FA mri_rf_pulse_sim.ui_prop.scalar                         % [°] Flip angle as defined in Siemens : scaled by a 1ms 180° RECT.
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
            self.n          = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n'         , value= 4                           );
            self.R          = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='R'         , value= 20                          );
            self.Fsweep     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='fsweep'    , value=0                 , unit='Hz');
            self.Siemens_FA = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='Siemens_FA', value=300               , unit='°' );
            self.b1cutoff   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='b1cutoff'  , value=  0.05, scale=1e2 , unit='%' );
            self.my_tbwp = self.R.get(); % hidden, internal value
            self.Fsweep.set( self.get_hs_bandwidth()/2 )
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

            self.B1 = self.B1 * ref_B1 * (self.duration/hsn_amplitude_integral) * (self.Siemens_FA/ref_FA) * (ref_duration/self.duration);

        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_hs_bandwidth();
        end % fcn

        function value = get_hs_bandwidth(self)
            value = self.my_tbwp / self.duration;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('[%s] { HS%d_R%g / HS%d_Fsweep%g } : n=%s R=%s Fsweep=%s Siemens_FA=%s  cutoff=%s', ...
                mfilename, self.n.value, self.R.value, self.n.value, self.Fsweep.value, ...
                self.n.repr, self.R.repr, self.Fsweep.repr, self.Siemens_FA.repr, self.b1cutoff.repr);
        end % fcn

        function init_specific_gui(self, container)
            pos1 = [0.00 0.30 1.00 0.70];
            pos2 = [0.00 0.00 1.00 0.30];

            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n, self.Siemens_FA, self.b1cutoff], ...
                pos1);

            panel_bw = uipanel(Parent=container, Units="normalized", Position=pos2, BackgroundColor=container.BackgroundColor);
            self.R     .add_uicontrol(panel_bw, [0.00 0.00 0.50 1.00])
            self.Fsweep.add_uicontrol(panel_bw, [0.50 0.00 0.50 1.00])
        end % fcn

        % override the default method
        function callback_update(self, ~, ~)

            is_new_R = abs(self.R      - self.my_tbwp                ) > 0;
            is_new_F = abs(self.Fsweep - self.my_tbwp/self.duration/2) > 0;

            if is_new_R && is_new_F
                warning('wtf ?    is_new_R && is_new_F ')
            elseif is_new_R
                self.my_tbwp = self.R.value;
                self.Fsweep.set(self.my_tbwp/self.duration/2);
            elseif is_new_F
                self.my_tbwp = self.Fsweep * 2 * self.duration;a
                self.R.set(self.my_tbwp);
            else
                % pass
            end

            self.notify_parent();

        end % fcn

    end % meths

    properties (GetAccess = private, SetAccess = private, Hidden)
        my_tbwp (1,1) double
    end % props

end % class
