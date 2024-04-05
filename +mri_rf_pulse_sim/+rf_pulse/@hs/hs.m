classdef hs < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Hyperbolic Secant

    properties (GetAccess = public, SetAccess = public)
        bw    mri_rf_pulse_sim.ui_prop.scalar                              % [Hz] target bandwidth of the pulse, in kilo Hertz
        b1max mri_rf_pulse_sim.ui_prop.scalar                              % [T] RF waveform amplitude amplitude
        b1cutoff mri_rf_pulse_sim.ui_prop.scalar                           % [] RF waveform cutoff, in percentage (%)
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
        beta                                                               % [rad/s]
    end % props

    methods % no attribute for dependent properties
        function value = get.bandwidth          (self); value = self.bw.get();                          end
        function value = get.beta               (self); value = asech(self.b1cutoff.get());             end
    end % meths

    methods (Access = public)

        % constructor
        function self = hs()
            self.bw       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='bw'      , value=2000   , scale=1e-3, unit='kHz');
            self.b1max    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='b1max'   , value=  20e-6, scale=1e6 , unit='µT' );
            self.b1cutoff = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='b1cutoff', value=   0.01, scale=1e2 , unit='%'  );
            self.generate_hs();
        end % fcn

        function generate(self) % #abstract
            self.generate_hs();
        end % fcn

        function generate_hs(self)
            self.time = linspace(0, self.duration, self.n_points);

            % reshape time so the magnitude waveform only depends on the cutoff
            T = (2*self.time / self.duration) - 1;

            % base waveforms
            magnitude = self.b1max*sech(self.beta * T);
            freq      = tanh(self.beta*T);

            % get phase from freq
            freq      = freq/max(freq) * self.bw*pi;
            phase     = self.freq2phase(freq);

            % final pulse shape
            self.B1 = magnitude .* exp(1j * phase);
            self.GZ = ones(size(self.time)) * self.GZavg;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('[%s] : BW=%s  B1max=%s  cutoff=%s', ...
                mfilename, self.bw.repr, self.b1max.repr, self.b1cutoff.repr);
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.bw, self.b1max, self.b1cutoff]...
                );
        end % fcn

    end % meths

end % class
