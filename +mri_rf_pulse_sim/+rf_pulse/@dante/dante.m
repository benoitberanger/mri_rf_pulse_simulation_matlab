classdef dante < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Morris GA, Freeman R. Selective excitation in Fourier transform
    % nuclear magnetic resonance. 1978. J Magn Reson. 2011
    % Dec;213(2):214-43. doi: 10.1016/j.jmr.2011.08.031. PMID: 22152346.
    %
    % Li, L., Miller, K.L. and Jezzard, P. (2012), DANTE-prepared pulse
    % trains: A novel approach to motion-sensitized and motion-suppressed
    % quantitative magnetic resonance imaging. Magn Reson Med, 68:
    % 1423-1438. https://doi.org/10.1002/mrm.24142

    properties (GetAccess = public, SetAccess = public)
        flip_angle        mri_rf_pulse_sim.ui_prop.scalar                  % [deg] flip angle
        subpulse_number   mri_rf_pulse_sim.ui_prop.scalar                  % [] it affects th TBWP, hence the slice profile
        subpulse_duration mri_rf_pulse_sim.ui_prop.scalar                  % [s] duration of each RECT subpluse, high subpulse duration means high maximum gradient
        phase_alternation mri_rf_pulse_sim.ui_prop.bool                    % [] keep phase at 0° for each subpulse, or alternate by 180°
        use_blip          mri_rf_pulse_sim.ui_prop.bool                    % [] use blip gradients between subpulse, or use continuous slice gradient
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        blip_duration                                                      % [s]
    end % props

    methods % no attribute for dependent properties

        function value = get.blip_duration(self)
            value = (self.duration - self.subpulse_duration) / (self.subpulse_number-1) - self.subpulse_duration;
        end

    end % meths

    methods (Access = public)

        % constructor
        function self = dante()
            self.flip_angle        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle'       , value= 90       , unit='°'                  );
            self.subpulse_number   = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='subpulse_number'  , value= 10                                   );
            self.subpulse_duration = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='subpulse_duration', value=100 * 1e-6, unit='us'      , scale=1e6);
            self.phase_alternation = mri_rf_pulse_sim.ui_prop.bool  (parent=self, name='phase_alternation', value=true      , text='phase_alternation'  );
            self.use_blip          = mri_rf_pulse_sim.ui_prop.bool  (parent=self, name='use_blip'         , value=true      , text='use_blip'           );
            self.generate_DANTE();
        end % fcn

        function generate(self) % #abstract
            self.generate_DANTE();
        end % fcn

        function generate_DANTE(self)
            self.assert_nonempty_prop({'n_points', 'duration','flip_angle', 'subpulse_number', 'subpulse_duration'})

            self.time = linspace(0, self.duration.value, self.n_points.value);

            MAG = zeros(size(self.time));
            PHA = zeros(size(self.time));
            if self.use_blip.get()
                GZ = zeros(size(self.time));
            else
                GZ = ones(size(self.time));
            end

            sample_subpulse = self.n_points * self.subpulse_duration/self.duration; % keep float
            sample_blip     = self.n_points * self.blip_duration    /self.duration; % keep float

            n_subpulse = 0;
            n_blip     = 0;

            gz_increase = 1 / ((sample_blip-2)/2);
            gz_slope_sign = +1;
            phase_increament = +180; % in degree

            for idx = 1 : self.n_points.get()

                % ensure first and last points are 0
                if idx == 1 || idx == self.n_points.get()
                    continue
                end

                if n_subpulse == 0 % initialization : start with a subpulse

                    if idx <= sample_subpulse
                        MAG(idx) = 1;
                        if self.phase_alternation.get()
                            PHA(idx) = phase_increament;
                        end
                    else
                        n_subpulse = 1;
                        phase_increament = -phase_increament;
                    end

                elseif n_blip == n_subpulse % fill subpulse

                    if idx <= sample_subpulse*(n_subpulse+1) + sample_blip*n_blip
                        MAG(idx) = 1;
                        if self.phase_alternation.get()
                            PHA(idx) = phase_increament;
                        end
                    else
                        n_subpulse = n_subpulse + 1;
                        phase_increament = -phase_increament;
                    end

                elseif n_blip < n_subpulse % fill blip

                    if idx <= sample_subpulse*n_subpulse + sample_blip*(n_blip+1)
                        if self.use_blip.get()
                            GZ(idx) = GZ(idx-1) + gz_slope_sign*gz_increase;
                            if GZ(idx) >= 1
                                gz_slope_sign = -1;
                            end
                        end
                    else
                        n_blip = n_blip + 1;
                        gz_slope_sign = +1;
                    end

                end

            end

            % scale waveform to the desired flip angle
            MAG = MAG / trapz(self.time, MAG); % normalize integral
            MAG = MAG * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.B1  = MAG .* exp(1j * deg2rad(PHA));

            % scale gradient -> for slice thickness
            self.GZ = self.GZavg / mean(GZ) * GZ;

        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_dante_bandwidth();
        end % fcn

        function value = get_dante_bandwidth(self)
            value = 1 / self.duration;
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  flip_angle=%s  subpulse_number=%s  subpulse_duration=%s',...
                mfilename, self.flip_angle.repr, self.subpulse_number.repr, self.subpulse_duration.repr);
        end % fcn

        function init_specific_gui(self, container)  % #abstract
            self.phase_alternation.add_uicontrol(...
                container,...
                [0.2 0.0 0.3 0.2]...
                );
            self.use_blip.add_uicontrol(...
                container,...
                [0.7 0.0 0.3 0.2]...
                );
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.subpulse_number self.subpulse_duration self.flip_angle],...
                [0.0 0.2 1.0 0.8]...
                );
        end % fcn

    end % meths

end % class
