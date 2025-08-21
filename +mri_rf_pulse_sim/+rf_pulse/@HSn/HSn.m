classdef HSn < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Hyperbolic Secant of order `n`, as implemented in **Siemens** scanners
    % With Gradient Modulation, it becomes a GOIA_HS

    properties (GetAccess = public, SetAccess = public)
        AM_power   mri_rf_pulse_sim.ui_prop.scalar                         % [] power factor of the magnitude waveform
        GM_power   mri_rf_pulse_sim.ui_prop.scalar                         % [] power factor of the gradient  waveform
        GM_dip     mri_rf_pulse_sim.ui_prop.scalar                         % [] dip in the gradient waveform : 0 is no dip (==flat), 1 is full dip
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
            self.AM_power   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='AM_power'  , value= 4                           );
            self.GM_power   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='GM_power'  , value= 0                           );
            self.GM_dip     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='GM_dip'    , value= 0.80                        );
            self.R          = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='R'         , value= 20                          );
            self.Fsweep     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='fsweep'    , value=0                 , unit='Hz');
            self.Siemens_FA = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='Siemens_FA', value=300               , unit='°' );
            self.b1cutoff   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='b1cutoff'  , value=  0.01, scale=1e2 , unit='%' );
            self.my_tbwp = self.R.get(); % hidden, internal value
            self.Fsweep.set( self.get_hs_bandwidth()/2 )
            self.generate_HSn();
        end % fcn

        function generate(self) % #abstract
            self.generate_HSn();
        end % fcn

        function generate_HSn(self)

            % --- prepare pulse waveform ---

            self.time = linspace(0, self.duration, self.n_points);

            % reshape time so the magnitude waveform only depends on the cutoff
            T = (2*self.time / self.duration) - 1;

            % base waveforms
            magnitude     =                                 sech(self.beta * T.^self.AM_power);
            if self.GZavg > 0
                gradient  = self.GZavg * (1 - self.GM_dip * sech(self.beta * T.^self.GM_power));
                freq      = cumtrapz(self.time, magnitude.^2 ./ gradient);
            else
                gradient  = zeros(size(self.time));
                freq      = cumtrapz(self.time, magnitude.^2);
            end

            % get phase from freq
            freq      = freq - mean(freq);              % center
            freq      = freq / max (freq);              % normalize
            if self.GZavg > 0
                freq  = freq .* gradient/max(gradient); % reshape
            end
            freq      = freq * self.bandwidth/2 * 2*pi; % scale
            phase     = self.freq2phase(freq);

            % final pulse shape (before magnitude scaling)
            self.B1 = magnitude .* exp(1j * phase);
            self.GZ = gradient;

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
            txt = sprintf('[%s] { HS%d_R%g / HS%d_Fsweep%g } : AM_power=%s GM_power=%s GM_dip=%s R=%s Fsweep=%s Siemens_FA=%s cutoff=%s', ...
                mfilename, self.AM_power.value, self.R.value, self.AM_power.value, self.Fsweep.value, ...
                self.AM_power.repr, self.GM_power.repr, self.GM_dip.repr, self.R.repr, self.Fsweep.repr, self.Siemens_FA.repr, self.b1cutoff.repr);
        end % fcn

        function init_specific_gui(self, container)
            pos1 = [0.00 0.30 1.00 0.70];
            pos2 = [0.00 0.00 1.00 0.30];

            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.AM_power, self.GM_power, self.GM_dip, self.Siemens_FA, self.b1cutoff], ...
                pos1);
            self.AM_power  .edit.Tooltip = "Power factor of Amplitude Modulation";
            self.GM_power  .edit.Tooltip = "Power factor of Gradient Modulation (HSn -> GOIA_HS)";
            self.GM_dip    .edit.Tooltip = "dip in the Gradient Modulation, from 0 (no dip=flat gradient) to 1 (100% dip of Gradient Modulation)";
            self.Siemens_FA.edit.Tooltip = "Equivalent FlipAngle in Siemens scanners, scaled by a 1ms 180° RECT";
            self.b1cutoff  .edit.Tooltip = "Percentage (%) of B1 cutoff : beta=asech(b1cutoff)";

            panel_bw = uibuttongroup(Parent=container, Units="normalized", Position=pos2, BackgroundColor=container.BackgroundColor);
            uicontrol(Parent=panel_bw, Style="radiobutton", BackgroundColor=container.BackgroundColor, Units="normalized", ...
                String="R>F", Position=[0.00 0.00 0.15 1.00], Tooltip="Keep R when duration is modified")
            uicontrol(Parent=panel_bw, Style="radiobutton", BackgroundColor=container.BackgroundColor, Units="normalized", ...
                String="F>R", Position=[0.15 0.00 0.15 1.00], Tooltip="Keep Fsweep when duration is modified")
            self.R     .add_uicontrol(panel_bw, [0.30 0.00 0.30 1.00])
            self.Fsweep.add_uicontrol(panel_bw, [0.60 0.00 0.30 1.00])
            self.R     .edit.Tooltip = "R = TimeBandWidthProduct= Time * BandWidth, quality factor)";
            self.Fsweep.edit.Tooltip = "Frequency Modulation will sweep from -Fsweep to +Fsweep";

        end % fcn

        % override the default method
        function callback_update(self, ~, ~)

            is_new_D = abs(self.duration - (self.time(end)-self.time(1))) > 0;

            if is_new_D

                panel = self.R.edit.Parent;
                switch panel.SelectedObject.String
                    case "R>F"
                        self.Fsweep.set(self.my_tbwp / self.duration / 2);
                    case "F>R"
                        self.R.set(self.Fsweep * 2 * self.duration);
                        self.my_tbwp = self.Fsweep * 2 * self.duration;
                end

            else
                is_new_R = abs(self.R        - self.my_tbwp                 ) > 0;
                is_new_F = abs(self.Fsweep   - self.my_tbwp/self.duration/2 ) > 0;

                if is_new_R && is_new_F
                    warning('wtf ?    is_new_R && is_new_F ')
                elseif is_new_R
                    self.my_tbwp = self.R.value;
                    self.Fsweep.set(self.my_tbwp/self.duration/2);
                elseif is_new_F
                    self.my_tbwp = self.Fsweep * 2 * self.duration;
                    self.R.set(self.my_tbwp);
                else
                    % pass
                end
            end

            self.notify_parent();

        end % fcn

    end % meths

    properties (GetAccess = private, SetAccess = private, Hidden)
        my_tbwp (1,1) double
    end % props

end % class
