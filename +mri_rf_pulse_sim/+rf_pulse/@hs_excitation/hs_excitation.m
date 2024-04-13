classdef hs_excitation < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Wastling, S.J. and Barker, G.J. (2015), Designing hyperbolic secant
    % excitation pulses to reduce signal dropout in gradient-echo
    % echo-planar imaging. Magn. Reson. Med., 74: 661-672.
    % https://doi.org/10.1002/mrm.25444

    properties (GetAccess = public, SetAccess = public)
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle
        beta mri_rf_pulse_sim.ui_prop.scalar                               % [rad/s]
        mu   mri_rf_pulse_sim.ui_prop.scalar                               % [] frequency sweep factor
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
        Amax                                                               % [T]
    end % props

    methods % no attribute for dependent properties
        
        function value = get.bandwidth(self)
            % Analytic expression for the bandwidth, depending on the flip angle.
            FA = deg2rad(self.flip_angle.get());
            value = self.beta/pi^2 * ...
                acosh( ...
                (cosh(pi*self.mu)*(cos(FA)-0.5*sqrt(3+cos(FA)^2)) + cos(FA) -1 ) ...
                /...
                (0.5*sqrt(3+cos(FA)^2) -1) );
        end% fcn
        
        function value = get.Amax(self)
            % Analytic expression for the max amplitude, depending on the flip angle.
            FA = deg2rad(self.flip_angle.get());
            value = (self.beta / self.gamma) * ...
                sqrt( ...
                (acos( cos(FA)*cosh(pi*self.mu/2)^2 + sinh(pi*self.mu/2)^2 ) / pi )^2 ...
                + ...
                self.mu^2);
        end % fcn
        
    end % meths

    methods (Access = public)

        % constructor
        function self = hs_excitation()
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=90  , unit='°'    );
            self.beta       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='beta'      , value=3040, unit='rad/s');
            self.mu         = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='mu'        , value=4.25              );
            self.generate_hs_excitation();
        end % fcn

        function generate(self) % #abstract
            self.generate_hs_excitation();
        end % fcn

        function generate_hs_excitation(self)
            self.assert_nonempty_prop({'Amax', 'beta', 'mu'})

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points);

            magnitude = self.Amax*sech(self.beta * self.time);

            phase = self.mu * log( sech(self.beta * self.time) ) + self.mu * self.Amax;

            self.B1 = magnitude .* exp(1j * phase);
            self.GZ = ones(size(self.time)) * self.GZavg;
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s] : BW=%gHz  flip_angle=%s  beta=%s  mu=%s',...
                mfilename, self.bandwidth, self.flip_angle.repr, self.beta.repr, self.mu.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.flip_angle, self.beta, self.mu]...
                );
        end % fcn

    end % meths

end % class
