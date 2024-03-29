classdef bir4_degraaf1995 < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % de Graaf RA, Luo Y, Terpstra M, Merkle H, Garwood M. A new
    % localization method using an adiabatic pulse, BIR-4. J Magn Reson B.
    % 1995 Mar;106(3):245-52. doi: 10.1006/jmrb.1995.1040. PMID: 7719624.

    properties (GetAccess = public, SetAccess = public)
        gammaB1max   mri_rf_pulse_sim.ui_prop.scalar                       % [Hz] (gamma * B1max), like in the article
        flip_angle   mri_rf_pulse_sim.ui_prop.scalar                       % [deg] flip angle
        Beta         mri_rf_pulse_sim.ui_prop.scalar                       % []
        dWmax        mri_rf_pulse_sim.ui_prop.scalar                       % [] frequency sweep factor
        n_transients mri_rf_pulse_sim.ui_prop.list                         % [] number of "transients"==BIR-4 with DeltaPhi in the article (phase cycling)
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
        delta_phase                                                        % [deg]
    end % props

    methods % no attribute for dependent properties
        function value = get.bandwidth(self)
            value = self.dWmax;
        end% % fcn
        function value = get.delta_phase(self)
            value = 180 + self.flip_angle/2;
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = bir4_degraaf1995()
            self.n_points.value = 512;        % Need more points for numerical stability
            self.duration.value = 2.8 * 1e-3; % like in the article
            self.gammaB1max     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='gammaB1max'  , value= 7000  , unit='Hz');
            self.flip_angle     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle'  , value=   90  , unit='°' );
            self.Beta           = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='Beta'        , value=    5.3           );
            self.dWmax          = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='dWmax'       , value= 3571  , unit='Hz');
            self.n_transients   = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='n_transients', items=[1,2,4], value=  1);
            self.generate_bir4_degraaf1995();
        end % fcn

        function generate(self) % #abstract
            self.generate_bir4_degraaf1995();
        end % fcn

        function generate_bir4_degraaf1995(self)
            % --- same terminology and notations as in the article ---

            assert(self.n_transients.value == 1 || self.n_transients.value == 2 || self.n_transients.value == 4, 'n_transients must be 1, 2 or 4')

            Tp = self.duration.value;
            B1max = self.gammaB1max * 2*pi / self.gamma;

            B1 = @(t) B1max * sech( self.Beta*4*t/Tp );
            PH = @(t) pi*self.dWmax*Tp/(2*self.Beta) * log(cosh(4*self.Beta*t/Tp));

            t = linspace(0, Tp, self.n_points.value);

            c1 =              t<=0.25*Tp;
            c2 = t>=0.25*Tp & t<=0.50*Tp;
            c3 = t>=0.50*Tp & t<=0.75*Tp;
            c4 = t>=0.75*Tp             ;

            t1 = t(c1);
            t2 = t(c2);
            t3 = t(c3);
            t4 = t(c4);

            MAG = nan(size(t)); % pre-allocation
            MAG(c1) = B1(t1         );
            MAG(c2) = B1(Tp/2 - t2  );
            MAG(c3) = B1(t3   - Tp/2);
            MAG(c4) = B1(t4   - Tp  );

            PHA = nan(size(t)); % pre-allocation
            PHA(c1) = PH(t1         );
            PHA(c2) = PH(Tp/2 - t2  );
            PHA(c3) = PH(t3   - Tp/2);
            PHA(c4) = PH(t4   - Tp  );

            switch self.n_transients.value
                case 1
                    PHA(c2) = PHA(c2) + deg2rad(self.delta_phase);
                    PHA(c3) = PHA(c3) + deg2rad(self.delta_phase);
                    self.time = t;
                    self.B1 = MAG .* exp(1j * PHA);
                case 2
                    PHA_000 = PHA; % dont add phase term
                    PHA_090 = PHA; % add 90°
                    PHA_090(c2) = PHA_090(c2) + deg2rad(090);
                    PHA_090(c3) = PHA_090(c3) + deg2rad(090);
                    self.B1 = [MAG MAG] .* exp(1j * [PHA_000 PHA_090]);
                    self.time = linspace(0, Tp*2, self.n_points.value*2);
                case 4
                    PHA_000 = PHA;
                    PHA_090 = PHA;
                    PHA_180 = PHA;
                    PHA_270 = PHA;
                    PHA_090(c2) = PHA_090(c2) + deg2rad(090);
                    PHA_090(c3) = PHA_090(c3) + deg2rad(090);
                    PHA_180(c2) = PHA_180(c2) + deg2rad(180);
                    PHA_180(c3) = PHA_180(c3) + deg2rad(180);
                    PHA_270(c2) = PHA_270(c2) + deg2rad(270);
                    PHA_270(c3) = PHA_270(c3) + deg2rad(270);
                    self.B1 = [MAG MAG MAG MAG] .* exp(1j * [PHA_000 PHA_090 PHA_180 PHA_270]);
                    self.time = linspace(0, Tp*4, self.n_points.value*4);
            end

            self.GZ = ones(size(self.time)) * self.GZavg;
        end

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  gammaB1max=%s  FA=%s  beta=%s  dWmax=%s',...
                mfilename, self.gammaB1max.repr, self.flip_angle.repr, self.Beta.repr, self.dWmax.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.gammaB1max, self.flip_angle, self.Beta, self.dWmax],...
                [0 0 0.8 1]);
            self.n_transients.add_uicontrol(container, [0.8 0 0.2 1])
        end % fcn

    end % meths

end % class
