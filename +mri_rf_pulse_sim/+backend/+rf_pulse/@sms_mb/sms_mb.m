classdef (Abstract) sms_mb < handle
    % Barth M, Breuer F, Koopmans PJ, Norris DG, Poser BA. Simultaneous
    % multislice (SMS) imaging techniques. Magn Reson Med. 2016
    % Jan;75(1):63-81. doi: 10.1002/mrm.25897. Epub 2015 Aug 26. PMID:
    % 26308571; PMCID: PMC4915494.

    % Auerbach EJ, Xu J, Yacoub E, Moeller S, Uğurbil K. Multiband
    % accelerated spin-echo echo planar imaging with reduced peak RF power
    % using time-shifted RF pulses. Magn Reson Med. 2013 May;69(5):1261-7.
    % doi: 10.1002/mrm.24719. Epub 2013 Mar 6. PMID: 23468087; PMCID:
    % PMC3769699.

    % Wong E. Optimized Phase Schedules for Minimizing Peak RF Power in
    % Simultaneous Multi-Slice RF Excitation Pulses. ISMRM 2012 Abstract
    % #2209; https://archive.ismrm.org/2012/2209.html

    properties (GetAccess = public, SetAccess = public)
        n_slice             mri_rf_pulse_sim.ui_prop.scalar                % []  number of slices, from 1 to +Inf
        slice_distance      mri_rf_pulse_sim.ui_prop.scalar                % [m] distance between each slice
        time_shifted        mri_rf_pulse_sim.ui_prop.bool                  % [] time-shifted to reduce peak B1 (Auerbach 2013)
        temporal_shift      mri_rf_pulse_sim.ui_prop.scalar                % [] from 0 to +Inf
        rf_phase_scrambling mri_rf_pulse_sim.ui_prop.bool                  % [] optimize inter-band phase offsets(ISMRM 2012, #2209)
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        band_seperation (1,1) double                                       % Hz
    end % props

    methods % no attribute for dependent properties
        function value = get.band_seperation(self)
            value = self.bandwidth * self.slice_distance/self.slice_thickness;
        end
    end % meths

    methods(Access = public)

        % constructor
        function self = sms_mb()
            self.n_slice             = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_slice'            , value=3                                        );
            self.slice_distance      = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='slice_distance'     , value=6 * 1e-3, unit='mm'           , scale=1e3);
            self.time_shifted        = mri_rf_pulse_sim.ui_prop.bool  (parent=self, name='time_shifted'       , value=false   , text='time_shifted'            );
            self.temporal_shift      = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='temporal_shift'     , value=0.25                                     );
            self.rf_phase_scrambling = mri_rf_pulse_sim.ui_prop.bool  (parent=self, name='rf_phase_scrambling', value=false   , text='rf_phase_scrambling'     );
        end

        function mb_phase_modulation(self)

            % relative spatial positon of the slice
            % mb3->[-1 0 1]
            % mb4->[-1.5 -0.5 +0.5 +1.5]
            offset_vect = (1:self.n_slice.get()) - (self.n_slice.get()+1)/2;

            if self.rf_phase_scrambling.get()
                phase_offsets = self.get_phase_offsets();
            end

            if self.time_shifted.get()
                warning('!!! time shift NOT working yet !!!')

                n_points_time_shifted = round(self.n_points * self.temporal_shift);
                n_points_shift = round( self.n_points * (1 + self.temporal_shift*(self.n_slice-1)) );

                subpulse_b1 = zeros(self.n_slice.get(), n_points_shift);
                offset = 1;

                for idx = 1 : length(offset_vect)
                    if self.rf_phase_scrambling.get()
                        mb_phase_modulation = exp(1j * (self.gamma * self.GZavg * self.slice_distance*offset_vect(idx) * self.time + phase_offsets(idx)));
                    else
                        mb_phase_modulation = exp(1j * 2*pi* self.band_seperation * offset_vect(idx) * self.time);
                    end
                    time_shifted_idx = offset:(offset+self.n_points-1);
                    subpulse_b1(idx, time_shifted_idx) = self.B1 .* mb_phase_modulation;
                    offset = offset + n_points_time_shifted;
                end
                mb_B1 = sum(subpulse_b1, 1);
                mb_time = linspace(self.time(1),self.time(end),length(mb_B1));

                self.B1 = interp1(mb_time,mb_B1,self.time);

            else

                % compute the phase modution : each slice has its own delta of central frequency.
                subpulse_b1 = zeros(self.n_slice.get(), self.n_points.get());
                for idx = 1 : length(offset_vect)
                    if self.rf_phase_scrambling.get()
                        mb_phase_modulation = exp(1j * (self.gamma * self.GZavg * self.slice_distance*offset_vect(idx) * self.time + phase_offsets(idx)));
                    else
                        mb_phase_modulation = exp(1j * 2*pi* self.band_seperation * offset_vect(idx) * self.time);
                    end
                    subpulse_b1(idx, :) = self.B1 .* mb_phase_modulation;
                end
                self.B1 = sum(subpulse_b1, 1);

            end


        end % fcn

        function init_mb_gui(self, container)
            self.n_slice            .add_uicontrol(container, [0.00 0.70 1.00 0.30])
            self.slice_distance     .add_uicontrol(container, [0.00 0.40 1.00 0.30])
            self.time_shifted       .add_uicontrol(container, [0.00 0.20 0.50 0.20])
            self.temporal_shift     .add_uicontrol(container, [0.00 0.00 1.00 0.20])
            self.rf_phase_scrambling.add_uicontrol(container, [0.50 0.20 0.50 0.20])
        end % fcn

    end % meths

    methods(Access = protected)

        function val = get_phase_offsets(self)
            offsets = ...
                {
                0 % 1
                [0, 0] % 2
                [0, 0.730, 4.602] % 3
                [0, 3.875, 5.9400, 6.197] % 4
                [0, 3.778, 5.335, 0.872, 0.471] % 5
                [0, 2.005, 1.6744, 5.012, 5.736, 4.123] % 6
                [0, 3.002, 5.998, 5.909, 2.624, 2.528, 2.440] % 7
                [0, 1.036, 3.4144, 3.778, 3.215, 1.756, 4.555, 2.4467] % 8
                [0, 1.250, 1.783, 3.558, 0.739, 3.319, 1.296, 0.5521, 5.332] % 9
                [0, 4.418, 2.3600, 0.677, 2.253, 3.472, 3.040, 3.9974, 1.192, 2.510] % 10
                [0, 5.041, 4.285, 3.001, 5.765, 4.295, 0.056, 4.2213, 6.040, 1.078, 2.759] % 11
                [0, 2.755, 5.491, 4.447, 0.231, 2.499, 3.539, 2.9931, 2.759, 5.376, 4.554, 3.479] % 12
                [0, 0.603, 0.009, 4.179, 4.361, 4.837, 0.816, 5.9995, 4.150, 0.417, 1.520, 4.517, 11.729] % 13
                [0, 3.997, 0.8300, 5.712, 3.838, 0.084, 1.685, 5.3328, 0.237, 0.506, 1.356, 4.025, 44.483, 4.084] % 14
                [0, 4.126, 2.266, 0.957, 4.603, 0.815, 3.475, 0.9977, 1.449, 1.192, 0.148, 0.939, 22.531, 3.612, 4.8001] % 15
                [0, 4.359, 3.5100, 4.410, 1.750, 3.357, 2.061, 5.9948, 3.000, 2.822, 0.627, 2.768, 33.875, 4.173, 4.2224, 5.941] % 16
                };
            if self.n_slice.get() <= length(offsets)
                val = offsets{self.n_slice.get()};
            else
                val = zeros(1,self.n_slice.get());
            end
        end % fcn

    end % meths

end % class
