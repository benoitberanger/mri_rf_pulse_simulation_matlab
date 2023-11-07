classdef hs < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Hyperbolic Secant

    properties (GetAccess = public, SetAccess = public)
        Amax mri_rf_pulse_sim.ui_prop.scalar                               % [T] B1max
        beta mri_rf_pulse_sim.ui_prop.scalar                               % [rad/s]
        mu   mri_rf_pulse_sim.ui_prop.scalar                               % [] frequency sweep factor
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]
        adiabatic_condition (1,1) double                                   % [T] B1max (Amax) minimal to be adiabatic
    end % props

    methods % no attribute for dependent properies
        function value = get.bandwidth(self)
            value = self.beta * self.mu  / pi;
        end% % fcn
        function value = get.adiabatic_condition(self)
            value = sqrt(self.mu.value) * self.beta / self.gamma;
        end % fcl
    end % meths

    methods (Access = public)

        % constructor
        function self = hs()
            self.duration.value = 7.68 * 1e-3;
            self.Amax = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='Amax'  , value= 20 * 1e-6, unit='µT', scale=1e6);
            self.beta = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='beta', value=1618                               );
            BW = 2000; % Hz
            self.mu   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='mu'  , value=BW*pi/self.beta                    );
            self.generate_hs();
        end % fcn

        function generate(self)
            self.generate_hs();
        end % fcn

        % generate time, AM, FM, GM
        function generate_hs(self)
            self.assert_nonempty_prop({'Amax', 'beta', 'mu'})

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points);

            magnitude = self.Amax*sech(self.beta * self.time);

            % some articles define the HS using frequency modulation :
            % freq = - self.mu * self.beta * tanh(self.beta * self.time);
            % phase = self.freq2phase(freq); % for integration
            % other define phase analyticaly (faster?) :
            % phase = self.mu * log( sech(self.beta * self.time) ) + self.mu * self.Amax;

            % the 2 computation methods only differ by the phase constat, at the origin
            % but it does not affect the slice profile in this simulation

            phase = self.mu * log( sech(self.beta * self.time) ) + self.mu * self.Amax;

            self.B1 = magnitude .* exp(1j * phase);
            self.GZ = ones(size(self.time)) * self.GZavg;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('hs : BW=%gHz  Amax=%gµT  beta=%g  mu=%g',...
                self.bandwidth, self.Amax.get(), self.beta.get(), self.mu.get());
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.Amax, self.beta, self.mu]...
                );
        end % fcn

    end % meths

end % class
