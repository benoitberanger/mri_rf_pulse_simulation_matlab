classdef dante < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % ref ?

    properties (GetAccess = public, SetAccess = public)
        flip_angle        mri_rf_pulse_sim.ui_prop.scalar                  % [deg] flip angle
        subpulse_number   mri_rf_pulse_sim.ui_prop.scalar                  % [] it affects th TBWP, hence the slice profile
        subpulse_duration mri_rf_pulse_sim.ui_prop.scalar                  % [s] duration of each RECT subpluse, high subpulse duration means high maximum gradient
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]
        blip_duration                                                      % [s]
    end % props

    methods % no attribute for dependent properies

        function value = get.bandwidth(self)
            value = self.subpulse_number / self.duration;
        end

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
            self.generate_DANTE();
        end % fcn

        function generate(self)
            self.generate_DANTE();
        end % fcn

        function generate_DANTE(self)
            self.assert_nonempty_prop({'n_points', 'duration','flip_angle', 'subpulse_number', 'subpulse_duration'})

            self.time = linspace(0, self.duration.value, self.n_points.value);

            B1 = zeros(size(self.time));
            GZ = zeros(size(self.time));

            sample_subpulse = self.n_points * self.subpulse_duration/self.duration; % keep float
            sample_blip     = self.n_points * self.blip_duration    /self.duration; % keep float

            n_subpulse = 0;
            n_blip     = 0;

            gz_increase = 1 / ((sample_blip-2)/2);
            gz_slope_sign = +1;

            for idx = 1 : self.n_points.get()

                % ensure first and last points are 0
                if idx == 1 || idx == self.n_points.get()
                    continue
                end

                if n_subpulse == 0 % initilization : start with a subpulse

                    if idx <= sample_subpulse
                        B1(idx) = 1;
                    else
                        n_subpulse = 1;
                    end

                elseif n_blip == n_subpulse % fill subpulse

                    if idx <= sample_subpulse*(n_subpulse+1) + sample_blip*n_blip
                        B1(idx) = 1;
                    else
                        n_subpulse = n_subpulse + 1;
                    end

                elseif n_blip < n_subpulse % fill blip

                    if idx <= sample_subpulse*n_subpulse + sample_blip*(n_blip+1)
                        GZ(idx) = GZ(idx-1) + gz_slope_sign*gz_increase;
                        if GZ(idx) >= 1
                            gz_slope_sign = -1;
                        end
                    else
                        n_blip = n_blip + 1;
                        gz_slope_sign = +1;
                    end

                end

            end

            % scale waveform to the desired flip angle
            B1 = B1 / trapz(self.time, B1); % normalize integral
            B1 = B1 * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.B1  = B1;

            % scale gradient -> for slice thickness
            self.GZ = self.GZavg / mean(GZ) * GZ;

        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('rect : flip_angle=%d°  subpulse_number=%d  subpulse_duration=%gus',...
                self.flip_angle.get(), self.subpulse_number.get(), self.subpulse_duration.get());
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.subpulse_number self.subpulse_duration self.flip_angle]...
                );
        end % fcn

    end % meths

end % class
