classdef goia_wurst < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Gradient Offset Independent Adiabaticity

    % Tannús A, Garwood M. Adiabatic pulses. NMR Biomed. 1997
    % Dec;10(8):423-34. doi:
    % 10.1002/(sici)1099-1492(199712)10:8<423::aid-nbm488>3.0.co;2-x. PMID:
    % 9542739.

    % Andronesi OC, Ramadan S, Ratai EM, Jennings D, Mountford CE, Sorensen AG.
    % Spectroscopic imaging with improved gradient modulated constant
    % adiabaticity pulses on high-field clinical scanners. J Magn Reson. 2010
    % Apr;203(2):283-93. doi: 10.1016/j.jmr.2010.01.010. Epub 2010 Jan 28.
    % PMID: 20163975; PMCID: PMC3214007.

    properties (GetAccess = public, SetAccess = public)

        bw    mri_rf_pulse_sim.ui_prop.scalar                              % [Hz] target bandwidth of the pulse, in kilo Hertz
        b1max mri_rf_pulse_sim.ui_prop.scalar                              % [T] pulse max RF amplitude

        f mri_rf_pulse_sim.ui_prop.scalar                                  % dip in the gradient profile : 0 is 100% dip, 1 is no dip == flat gradient
        n mri_rf_pulse_sim.ui_prop.scalar                                  % power factor of the magnitude shape
        m mri_rf_pulse_sim.ui_prop.scalar                                  % power factor of the gradient  shape

    end % props

    methods (Access = public)

        function self = goia_wurst()
            self.bw    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='bw'   , value=4000   , scale=1e-3 , unit='kHz'  );
            self.b1max = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='b1max', value=  20e-6, scale=1e6  , unit='µT'   );
            self.f     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='f'    , value=0.9                               );
            self.n     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n'    , value=4                                 );
            self.m     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='m'    , value=2                                 );
            self.generate_goia_hs();
        end % fcn

        function generate(self)
            self.generate_goia_hs();
        end % fcn

        function generate_goia_hs(self)
            self.time = linspace(0, self.duration, self.n_points);

            T = (2*self.time / self.duration) - 1;
            abs_sin = abs(sin((pi/2)*T));

            magnitude     = self.b1max *  (1           -        abs_sin.^self.n);
            if self.GZavg.get() > 0
                gradient  = self.GZavg * ((1 - self.f) + self.f*abs_sin.^self.m);
                freq      = cumtrapz(self.time, magnitude.^2 ./ gradient);
            else
                gradient  = zeros(size(self.time));
                freq      = cumtrapz(self.time, magnitude.^2);
            end
            freq      = freq - mean(freq);
            freq      = freq / max(freq);
            if self.GZavg.get() > 0
                freq  = freq .* gradient/max(gradient);
            end
            freq      = freq * self.bw * pi;
            phase     = self.freq2phase(freq);

            self.B1 = magnitude .* exp(1j * phase);
            self.GZ = gradient;
        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_goia_wurst_bandwidth();
        end % fcn

        function value = get_goia_wurst_bandwidth(self)
            value = self.bw.get();
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('[%s] : BW=%s B1max=%s f=%s  n=%s  m=%s', ...
                mfilename, self.bw.repr, self.b1max.repr, self.f.repr, self.n.repr, self.m.repr);
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.bw, self.b1max, self.f, self.n, self.m]...
                );
        end % fcn

    end % meths

end % class
