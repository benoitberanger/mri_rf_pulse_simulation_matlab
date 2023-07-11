classdef hs < mri_rf_pulse_sim.rf_pulse.base
    % Hyperbolic Secant

    properties (GetAccess = public, SetAccess = public)

        Amax   mri_rf_pulse_sim.ui_prop.scalar                               % [T] B1max
        beta mri_rf_pulse_sim.ui_prop.scalar                               % [rad/s]
        mu   mri_rf_pulse_sim.ui_prop.scalar                               % [] frequency sweep factor
        gz   mri_rf_pulse_sim.ui_prop.scalar                               % [T/m] slice/slab selection gradient

    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth (1,1) double                                             % Hz
    end % props

    methods % no attribute for dependent properies
        function value = get.bandwidth(self)
            value = self.beta * self.mu  / pi;
        end% % fcn
    end % meths

    methods (Access = public)

        % constructor
        function self = hs()
            self.n_points.value = 512; % we need more points, otherwise the numerical model will not be accurate for extrem dZ
            self.duration.value = 7.68 * 1e-3;
            self.Amax = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='Amax'  , value= 100 * 1e-6, unit='µT', scale=1e6);
            self.beta = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='beta', value=1618                               );
            BW = 2000; % Hz
            self.mu   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='mu'  , value=BW*pi/self.beta                    );
            self.gz   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='gz'  , value=  25 * 1e-3, unit='mT/m', scale=1e3);
            self.generate_hs();
        end % fcn

        function generate(self)
            self.generate_hs();
        end % fcn

        % generate time, AM, FM, GM
        function generate_hs(self)
            self.assert_nonempty_prop({'Amax', 'beta', 'mu', 'gz'})

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points);

            self.amplitude_modulation = self.Amax*sech(self.beta * self.time);
            self.frequency_modulation = -self.mu * self.beta * tanh(self.beta * self.time);
            self. gradient_modulation = ones(size(self.time)) * self.gz;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('hs : BW=%gHz  Amax=%gµT  beta=%g  mu=%g  gz=%gmT/m',...
                self.bandwidth, self.Amax.get(), self.beta.get(), self.mu.get(), self.gz.get());
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.Amax, self.beta, self.mu, self.gz]...
                );
        end % fcn

    end % meths

end % class
