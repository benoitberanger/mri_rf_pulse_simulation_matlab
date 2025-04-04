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
        % time_shifted   mri_rf_pulse_sim.ui_prop.bool                       % [] time-shifted to reduce peak B1 (Auerbach 2013)
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
            % self.time_shifted   = mri_rf_pulse_sim.ui_prop.bool  (parent=self, name='time_shifted'  , value=false   , text='time_shifted'            );
        end

        function mb_phase_modulation(self)

            % relative spatial positon of the slice
            % mb3->[-1 0 1]
            % mb4->[-1.5 -0.5 +0.5 +1.5]
            offset_vect = (1:self.n_slice.get()) - (self.n_slice.get()+1)/2;

            % compute the phase modution : each slice has its own delta of central frequency.
            subpulse_b1 = zeros(self.n_slice.get(), self.n_points.get());
            for idx = 1 : length(offset_vect)
                mb_phase_modulation = exp(1j * 2*pi* self.band_seperation * offset_vect(idx) * self.time);
                subpulse_b1(idx, :) = self.B1 .* mb_phase_modulation;
            end
            self.B1 = sum(subpulse_b1, 1);

        end % fcn

        function init_mb_gui(self, container)
            self.n_slice       .add_uicontrol(container, [0.00 0.60 1.00 0.40])
            self.slice_distance.add_uicontrol(container, [0.00 0.20 1.00 0.40])
            % self.time_shifted  .add_uicontrol(container, [0.00 0.00 1.00 0.20])
        end % fcn

    end % meths

end % class
