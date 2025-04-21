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

    properties (GetAccess = public, SetAccess = public)
        n_slice        mri_rf_pulse_sim.ui_prop.scalar                     % []  number of slices, from 1 to +Inf
        slice_distance mri_rf_pulse_sim.ui_prop.scalar                     % [m] distance between each slice
        time_shifted   mri_rf_pulse_sim.ui_prop.bool                       % [] time-shifted to reduce peak B1 (Auerbach 2013)
        temporal_shift mri_rf_pulse_sim.ui_prop.scalar                     % [] from 0 to +Inf
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
            self.n_slice        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_slice'       , value=3                                        );
            self.slice_distance = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='slice_distance', value=6 * 1e-3, unit='mm'           , scale=1e3);
            self.time_shifted   = mri_rf_pulse_sim.ui_prop.bool  (parent=self, name='time_shifted'  , value=false   , text='time_shifted'            );
            self.temporal_shift = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='temporal_shift', value=0.25                                     );
        end

        function mb_phase_modulation(self)

            % relative spatial positon of the slice
            % mb3->[-1 0 1]
            % mb4->[-1.5 -0.5 +0.5 +1.5]
            offset_vect = (1:self.n_slice.get()) - (self.n_slice.get()+1)/2;

            if self.time_shifted.get()
                warning('!!! time shift NOT working yet !!!')

                n_points_time_shifted = round(self.n_points * self.temporal_shift);
                n_points_shift = round( self.n_points * (1 + self.temporal_shift*(self.n_slice-1)) );

                subpulse_b1 = zeros(self.n_slice.get(), n_points_shift);
                offset = 1;
                for idx = 1 : length(offset_vect)
                    mb_phase_modulation = exp(1j * 2*pi* self.band_seperation * offset_vect(idx) * self.time);
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
                    mb_phase_modulation = exp(1j * 2*pi* self.band_seperation * offset_vect(idx) * self.time);
                    subpulse_b1(idx, :) = self.B1 .* mb_phase_modulation;
                end
                self.B1 = sum(subpulse_b1, 1);

            end


        end % fcn

        function init_mb_gui(self, container)
            self.n_slice       .add_uicontrol(container, [0.00 0.70 1.00 0.30])
            self.slice_distance.add_uicontrol(container, [0.00 0.40 1.00 0.30])
            self.time_shifted  .add_uicontrol(container, [0.00 0.20 1.00 0.20])
            self.temporal_shift.add_uicontrol(container, [0.00 0.00 1.00 0.20])
        end % fcn

    end % meths

end % class
