classdef sms_mb_hs < mri_rf_pulse_sim.rf_pulse.hs
    % Barth M, Breuer F, Koopmans PJ, Norris DG, Poser BA. Simultaneous
    % multislice (SMS) imaging techniques. Magn Reson Med. 2016
    % Jan;75(1):63-81. doi: 10.1002/mrm.25897. Epub 2015 Aug 26. PMID:
    % 26308571; PMCID: PMC4915494.

    properties (GetAccess = public, SetAccess = public)
        n_slice        mri_rf_pulse_sim.ui_prop.scalar                     % []  number of slices, from 1 to +Inf
        slice_distance mri_rf_pulse_sim.ui_prop.scalar                     % [m] distance between each slice
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        band_seperation (1,1) double                                       % Hz
    end % props

    methods % no attribute for dependent properies
        function value = get.band_seperation(self)
            value = self.bandwidth * self.slice_distance/self.slice_thickness;
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = sms_mb_hs()
            self.n_slice        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_slice'       , value=3                               );
            self.slice_distance = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='slice_distance', value= 5 * 1e-3, unit='mm', scale=1e3);
            self.generate_sms_mb_hs();
        end % fcn

        function generate(self)
            self.generate_sms_mb_hs();
        end % fcn

        function generate_sms_mb_hs(self)

            % generate SINC pulse : this is SingleBand pulse waveform
            self.generate_hs();

            % prepare slice offcet vector : integer number "representing" the slice index.
            if mod(self.n_slice.get(),2) == 0
                vect = linspace(-self.n_slice/2, self.n_slice/2, self.n_slice);
            else
                vect = linspace(-fix(self.n_slice/2), fix(self.n_slice/2), self.n_slice);
            end

            % compute the phase modution : each slice has its own delta of central frequency.
            % central frequency + gradient = slice postion in space
            % bandwidth + gradient = slice width
            mb_phase_mudulation = 0;
            for n = vect
                mb_phase_mudulation = mb_phase_mudulation + exp(1j * 2*pi* self.band_seperation * n * self.time);
            end

            self.B1 = self.B1 .* mb_phase_mudulation;
            % GM is already set using the SINC as base class

        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('sinc : n_slice=%d  slice_distance=%d  BW=%gHz  Amax=%gµT  beta=%g  mu=%g  gz=%gmT/m',...
                self.n_slice.get(), self.slice_distance.get(), self.bandwidth, self.Amax.get(), self.beta.get(), self.mu.get(), self.gz.get());
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n_slice self.slice_distance self.Amax, self.beta, self.mu, self.gz]...
                );

        end % fcn

    end % meths

end % class