classdef goia_wurst < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Gradient Offset Independent Adiabaticity

    % Andronesi OC, Ramadan S, Ratai EM, Jennings D, Mountford CE, Sorensen AG.
    % Spectroscopic imaging with improved gradient modulated constant
    % adiabaticity pulses on high-field clinical scanners. J Magn Reson. 2010
    % Apr;203(2):283-93. doi: 10.1016/j.jmr.2010.01.010. Epub 2010 Jan 28.
    % PMID: 20163975; PMCID: PMC3214007.

    properties (GetAccess = public, SetAccess = public)

        Amax  mri_rf_pulse_sim.ui_prop.scalar                              % [T] B1max
        mu  mri_rf_pulse_sim.ui_prop.scalar                                % [Hz] bandwidth of the frequency sweep
        f   mri_rf_pulse_sim.ui_prop.scalar
        n   mri_rf_pulse_sim.ui_prop.scalar
        m   mri_rf_pulse_sim.ui_prop.scalar

    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]
        adiabatic_condition (1,1) double                                   % [T] B1max (Amax) minimal to be adiabatic
    end % props

    methods % no attribute for dependent properties
        function value = get.bandwidth(self)
            value = self.beta * self.mu  / pi;
        end% % fcn
        function value = get.adiabatic_condition(self)
            value = sqrt(self.mu.value) * self.beta / self.gamma;
        end % fcl
    end % meths

    methods (Access = public)

        function self = goia_wurst()
            self.Amax = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='Amax', value= 100 * 1e-6, unit='µT'  , scale=1e6);
            self.mu   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='mu'  , value=2000       , unit='Hz'             );
            self.f    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='f'   , value=   0.9                             );
            self.n    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n'   , value=  16                               );
            self.m    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='m'   , value=   4                               );
            self.duration.value = 7.68 * 1e-3;
            self.generate_goia_wurst();
        end % fcn

        function generate(self)
            self.generate_goia_wurst();
        end % fcn

        function generate_goia_wurst(self)
            self.time = linspace(0, self.duration, self.n_points);

            T = (2*self.time / self.duration) - 1;

            magnitude = self.Amax *                    (1 - abs(sin(pi/2 * T)).^self.n.value);
            gradient  = self.GZavg   * (1 - self.f +    self.f*abs(sin(pi/2 * T)).^self.m.value);
            freq      = cumsum(magnitude.^2 ./ gradient) * self.duration / self.n_points;
            freq      = freq - freq(round(end/2));
            freq      = freq .* gradient;
            freq      = freq / max(abs(freq)) * self.mu / 2;
            phase     = self.freq2phase(freq);

            self.B1 = magnitude .* exp(1j * phase);
            self.GZ = gradient;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('goia_hs : Amax=%gµT  mu=%g  gz=%gmT/m  f=%g  n=%d  m=%d',...
                self.Amax.get(), self.mu.get(), self.gz.get(), self.f.get(), self.n.get(), self.m.get());
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.Amax, self.f self.gz, self.mu, self.n, self.m]...
                );
        end % fcn

    end % meths

end % class
