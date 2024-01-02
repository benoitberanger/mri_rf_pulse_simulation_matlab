classdef bir4_steawen1990 < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % STAEWEN, R. SCOTT MD; JOHNSON, ANTON J. BA; ROSS, BRIAN D. PHD;
    % PARRISH, TODD MSE; MERKLE, HELLMUT PHD; GARWOOD, MICHAEL PHD. 3-D
    % FLASH Imaging Using a Single Surface Coil and a New Adiabatic Pulse,
    % BIR-4. Investigative Radiology 25(5):p 559-567, May 1990.

    properties (GetAccess = public, SetAccess = public)
        Amax       mri_rf_pulse_sim.ui_prop.scalar                         % [T] B1max
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle
        Beta       mri_rf_pulse_sim.ui_prop.scalar                         % []
        tanKappa   mri_rf_pulse_sim.ui_prop.scalar                         % []
        dW0factor  mri_rf_pulse_sim.ui_prop.scalar                         % [] frequency sweep factor
    end % props

    properties (GetAccess = public, SetAccess = protected)
        bandwidth = 0                                                      % [Hz]  #abstract
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        delta_phase                                                        % [deg]
    end % props

    methods % no attribute for dependent properties
        function value = get.delta_phase(self)
            value = 180 + self.flip_angle/2;
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = bir4_steawen1990()
            self.slice_thickness.value = Inf; % non-selective pulse -> only watch the dB0 curves
            self.Amax       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='Amax'      , value=   20 * 1e-6, unit='µT', scale=1e6);
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=   90       , unit='°'            );
            self.Beta       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='Beta'      , value=   10                             );
            self.tanKappa   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='tanKappa'  , value=   10                             );
            self.dW0factor  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='dW0factor' , value=  100                             );
            self.generate_bir4_steawen1990();
        end % fcn

        function generate(self) % #abstract
            self.generate_bir4_steawen1990();
        end % fcn

        function generate_bir4_steawen1990(self)

            % check
            assert(mod(self.n_points.value,2)==0, 'n_points must be an even number')

            self.time = linspace(0, self.duration.value, self.n_points.value);

            % --- same terminology and notations as in the article ---

            t = self.time/(self.duration/4);
            t1 = t(        t<=1 );
            t2 = t( t>=1 & t<=2 );
            t3 = t( t>=2 & t<=3 );
            t4 = t( t>=3        );

            BETA = self.Beta.value;
            KAPPA = atan(self.tanKappa.value);

            a1 = tanh(BETA*( 1 - t1));
            a2 = tanh(BETA*(t2 -  1));
            a3 = tanh(BETA*( 3 - t3));
            a4 = tanh(BETA*(t4 -  3));
            a  = self.Amax * [a1 a2 a3 a4];

            w1 = tan(KAPPA*(t1  ))/tan(KAPPA);
            w2 = tan(KAPPA*(t2-2))/tan(KAPPA);
            w3 = tan(KAPPA*(t3-2))/tan(KAPPA);
            w4 = tan(KAPPA*(t4-4))/tan(KAPPA);
            w  = self.dW0factor *pi / self.duration * [w1 w2 w3 w4];

            p = self.freq2phase(w);

            % apply phase shift in the central part -> this produces the desired flip angle
            dp  = zeros(size(self.time));
            dp(t>=1 & t<3) = deg2rad(self.delta_phase);

            self.B1 = a .* exp(1j * (p + dp));

            self.GZ = ones(size(self.time)) * self.GZavg;

        end

        function txt = summary(self) % #abstract
            txt = sprintf('[%s] : Amax=%gµT  FA=%g°  beta=%g  tanKappa=%g  dWmax=%gHz',...
                mfilename, self.Amax.get(), self.flip_angle.get(), self.Beta.get(), self.tanKappa.get(), self.dWmax.get());
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.Amax, self.flip_angle, self.Beta, self.tanKappa, self.dW0factor]...
                );
        end % fcn

    end % meths

end % class
