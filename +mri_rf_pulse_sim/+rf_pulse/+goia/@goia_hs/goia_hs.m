classdef goia_hs < mri_rf_pulse_sim.rf_pulse.foci
    % Gradient Offset Independent Adiabaticity

    % Andronesi OC, Ramadan S, Ratai EM, Jennings D, Mountford CE, Sorensen AG.
    % Spectroscopic imaging with improved gradient modulated constant
    % adiabaticity pulses on high-field clinical scanners. J Magn Reson. 2010
    % Apr;203(2):283-93. doi: 10.1016/j.jmr.2010.01.010. Epub 2010 Jan 28.
    % PMID: 20163975; PMCID: PMC3214007.

    properties (GetAccess = public, SetAccess = public)

        f mri_rf_pulse_sim.ui_prop.scalar
        n mri_rf_pulse_sim.ui_prop.scalar
        m mri_rf_pulse_sim.ui_prop.scalar

    end % props

    methods (Access = public)

        function self = goia_hs()
            self.f = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='f', value=0.9);
            self.n = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n', value=8);
            self.m = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='m', value=4);
            self.beta.value = 5;
            self.mu.value = 2000;
            self.generate_goia_hs();
        end % fcn

        function generate(self)
            self.generate_goia_hs();
        end % fcn

        function generate_goia_hs(self)
            self.time = linspace(0, self.duration, self.n_points);

            T = (2*self.time / self.duration) - 1;

            magnitude = self.Amax     * sech(self.beta * T.^self.n.value);
            gradient  = self.gz       * (1 - self.f * sech(self.beta * T.^self.m.value));
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
            txt = sprintf('goia_hs : BW=%gHz  Amax=%gµT  beta=%g  mu=%g  gz=%gmT/m  f=%g  n=%d  m=%d',...
                self.bandwidth, self.Amax.get(), self.beta.get(), self.mu.get(), self.gz.get(), self.f.get(), self.n.get(), self.m.get());
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.Amax, self.beta, self.mu, self.f, self.gz, self.n, self.m]...
                );
        end % fcn

    end % meths

end % class
