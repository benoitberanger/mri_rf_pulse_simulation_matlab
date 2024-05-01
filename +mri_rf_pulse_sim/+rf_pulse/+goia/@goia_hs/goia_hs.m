classdef goia_hs < mri_rf_pulse_sim.backend.rf_pulse.abstract
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
        beta  mri_rf_pulse_sim.ui_prop.scalar                              % [rad/s]
        b1max mri_rf_pulse_sim.ui_prop.scalar                              % [T] RF waveform amplitude amplitude

        f mri_rf_pulse_sim.ui_prop.scalar                                  % dip in the gradient profile : 0 is 100% dip, 1 is no dip == flat gradient
        n mri_rf_pulse_sim.ui_prop.scalar                                  % power factor of the magnitude shape
        m mri_rf_pulse_sim.ui_prop.scalar                                  % power factor of the gradient  shape

    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
    end % props

    methods % no attribute for dependent properties
        function value = get.bandwidth(self); value = self.bw.get(); end
    end % meths

    methods (Access = public)

        function self = goia_hs()
            self.bw    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='bw'   , value=4000   , scale=1e-3 , unit='kHz'  );
            self.beta  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='beta' , value=   5   ,              unit='rad/s');
            self.b1max = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='b1max', value=  20e-6, scale=1e6  , unit='µT'   );
            self.f     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='f'    , value=0.9                               );
            self.n     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n'    , value=4                                 );
            self.m     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='m'    , value=2                                 );
            self.generate();
        end % fcn

        function generate(self)
            self.generate_goia_hs();
        end % fcn

        function generate_goia_hs(self)
            self.time = linspace(0, self.duration, self.n_points);

            T = (2*self.time / self.duration) - 1;

            magnitude = self.b1max *               sech(self.beta * T.^self.n) ;
            gradient  = self.GZavg * (1 - self.f * sech(self.beta * T.^self.m));
            freq      = cumtrapz(self.time,magnitude.^2 ./ gradient);
            freq      = freq - mean(freq);
            freq      = freq / max(freq);
            freq      = freq .* gradient/max(gradient);
            freq      = freq * self.bw * pi;
            phase     = self.freq2phase(freq);

            self.B1 = magnitude .* exp(1j * phase);
            self.GZ = gradient;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('[%s] : BW=%s  B1max=%s  beta=%s  f=%s  n=%s  m=%s', ...
                mfilename, self.bw.repr, self.b1max.repr, self.beta.repr, self.f.repr, self.n.repr, self.m.repr);
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.bw, self.b1max, self.beta, self.f, self.n, self.m]...
                );
        end % fcn

    end % meths

end % class
