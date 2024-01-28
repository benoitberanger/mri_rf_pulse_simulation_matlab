classdef sms_mb_hs < mri_rf_pulse_sim.rf_pulse.hs & mri_rf_pulse_sim.backend.rf_pulse.sms_mb

    methods (Access = public)

        % constructor
        function self = sms_mb_hs()
            self.generate_sms_mb_hs();
        end % fcn

        function generate(self) % #abstract
            self.generate_sms_mb_hs();
        end % fcn

        function generate_sms_mb_hs(self)

            % generate SINC pulse : this is SingleBand pulse waveform
            self.generate_hs();

            % apply multi-band phase modulation to B1
            self.mb_phase_modulation();
            % GM is already set using the HS as base class

        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s] : n_slice=%s  slice_distance=%s  BW=%gHz  Amax=%s  beta=%s  mu=%s',...
                mfilename, self.n_slice.repr, self.slice_distance.repr, self.bandwidth, self.Amax.repr, self.beta.repr, self.mu.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n_slice self.slice_distance self.Amax, self.beta, self.mu]...
                );

        end % fcn

    end % meths

end % class
