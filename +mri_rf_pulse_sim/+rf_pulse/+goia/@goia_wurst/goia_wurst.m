classdef goia_wurst < mri_rf_pulse_sim.rf_pulse.base
    % Gradient Offset Independent Adiabaticity

    % Andronesi OC, Ramadan S, Ratai EM, Jennings D, Mountford CE, Sorensen AG.
    % Spectroscopic imaging with improved gradient modulated constant
    % adiabaticity pulses on high-field clinical scanners. J Magn Reson. 2010
    % Apr;203(2):283-93. doi: 10.1016/j.jmr.2010.01.010. Epub 2010 Jan 28.
    % PMID: 20163975; PMCID: PMC3214007.

    properties (GetAccess = public, SetAccess = public)

        Amax  mri_rf_pulse_sim.ui_prop.scalar                               % [T] B1max
        gz  mri_rf_pulse_sim.ui_prop.scalar                               % [T/m] slice/slab selection gradient
        mu  mri_rf_pulse_sim.ui_prop.scalar                               % [Hz] bandwidth of the frequency sweep
        f   mri_rf_pulse_sim.ui_prop.scalar
        n   mri_rf_pulse_sim.ui_prop.scalar
        m   mri_rf_pulse_sim.ui_prop.scalar

    end % props

    methods (Access = public)

        function self = goia_wurst()
            self.Amax = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='Amax', value= 100 * 1e-6, unit='µT'  , scale=1e6);
            self.gz   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='gz'  , value=  25 * 1e-3, unit='mT/m', scale=1e3);
            self.mu   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='mu'  , value=2000       , unit='Hz'             );
            self.f    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='f'   , value=   0.9                             );
            self.n    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n'   , value=  16                               );
            self.m    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='m'   , value=   4                               );
            self.n_points.value = 512;
            self.duration.value = 7.68 * 1e-3;
            self.generate_goia_wurst();
        end % fcn

        function generate(self)
            self.generate_goia_wurst();
        end % fcn

        function generate_goia_wurst(self)
            self.time = linspace(0, self.duration, self.n_points);

            T = (2*self.time / self.duration) - 1;

            self.amplitude_modulation = self.Amax *                    (1 - abs(sin(pi/2 * T)).^self.n.value);
            self. gradient_modulation = self.gz   * (1 - self.f +    self.f*abs(sin(pi/2 * T)).^self.m.value);
            self.frequency_modulation = cumsum(self.amplitude_modulation.^2 ./ self.gradient_modulation) * self.duration / self.n_points;
            self.frequency_modulation = self.frequency_modulation - self.frequency_modulation(round(end/2));
            self.frequency_modulation = self.frequency_modulation .* self.gradient_modulation;
            self.frequency_modulation = self.frequency_modulation / max(abs(self.frequency_modulation)) * self.mu / 2;
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.Amax, self.f self.gz, self.mu, self.n, self.m]...
                );
        end % fcn

    end % meths

end % class
