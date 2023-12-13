classdef bir4_degraaf1995 < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % de Graaf RA, Luo Y, Terpstra M, Merkle H, Garwood M. A new
    % localization method using an adiabatic pulse, BIR-4. J Magn Reson B.
    % 1995 Mar;106(3):245-52. doi: 10.1006/jmrb.1995.1040. PMID: 7719624.

    properties (GetAccess = public, SetAccess = public)
        gammaB1max mri_rf_pulse_sim.ui_prop.scalar                         % [Hz] (gamma * B1max), like in the article
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle
        Beta       mri_rf_pulse_sim.ui_prop.scalar                         % []
        dWmax      mri_rf_pulse_sim.ui_prop.scalar                         % [] frequency sweep factor
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]
        delta_phase                                                        % [deg]
    end % props

    methods % no attribute for dependent properies
        function value = get.bandwidth(self)
            value = 0;
        end% % fcn
        function value = get.delta_phase(self)
            value = 180 + self.flip_angle/2;
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = bir4_degraaf1995()
            self.slice_thickness.value = Inf; % non-selective pulse -> only watch the dB0
            self.n_points.value = 512;        % Need more points for numerical stability
            self.duration.value = 2.8 * 1e-3; % like in the article
            self.gammaB1max = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='gammaB1max', value= 7000  , unit='Hz');
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=   90  , unit='°' );
            self.Beta       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='Beta'      , value=    5.3           );
            self.dWmax      = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='dWmax'     , value= 3571  , unit='Hz');
            self.generate_bir4_degraaf1995();
        end % fcn

        function generate(self)
            self.generate_bir4_degraaf1995();
        end % fcn

        function generate_bir4_degraaf1995(self)

            % --- same terminology and notations as in the article ---

            Tp = self.duration.value;
            B1max = self.gammaB1max * 2*pi / self.gamma;

            t = linspace(0, Tp, self.n_points.value);
            self.time = t;

            B1 = @(t) B1max * sech( self.Beta*4*t/Tp );
            PH = @(t) pi*self.dWmax*Tp/(2*self.Beta) * log(cosh(4*self.Beta*t/Tp));

            c1 =              t<=0.25*Tp;
            c2 = t>=0.25*Tp & t<=0.50*Tp;
            c3 = t>=0.50*Tp & t<=0.75*Tp;
            c4 = t>=0.75*Tp             ;

            t1 = t(c1);
            t2 = t(c2);
            t3 = t(c3);
            t4 = t(c4);

            MAG = nan(size(self.time)); % pre-allocation
            MAG(c1) = B1(t1         );
            MAG(c2) = B1(Tp/2 - t2  );
            MAG(c3) = B1(t3   - Tp/2);
            MAG(c4) = B1(t4   - Tp  );

            PHA = nan(size(self.time)); % pre-allocation
            PHA(c1) = PH(t1         );
            PHA(c2) = PH(Tp/2 - t2  ) + deg2rad(self.delta_phase);
            PHA(c3) = PH(t3   - Tp/2) + deg2rad(self.delta_phase);
            PHA(c4) = PH(t4   - Tp  );

            self.B1 = MAG .* exp(1j * PHA);

            self.GZ = ones(size(self.time)) * self.GZavg;

        end

        % synthesis text
        function txt = summary(self)
            txt = sprintf('BIR-4 : gammaB1max=%gHz  FA=%g°  beta=%g  dWmax=%gHz',...
                self.gammaB1max.get(), self.flip_angle.get(), self.Beta.get(), self.dWmax.get());
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.gammaB1max, self.flip_angle, self.Beta, self.dWmax]...
                );
        end % fcn

    end % meths

end % class
