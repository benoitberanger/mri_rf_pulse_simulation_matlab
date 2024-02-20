classdef sms_mb_sinc < mri_rf_pulse_sim.rf_pulse.sinc & mri_rf_pulse_sim.backend.rf_pulse.sms_mb

    methods (Access = public)

        % constructor
        function self = sms_mb_sinc()
            self.generate_sms_mb_sinc();
        end % fcn

        function generate(self) % #abstract
            self.generate_sms_mb_sinc();
        end % fcn

        function generate_sms_mb_sinc(self)

            % generate SINC pulse : this is SingleBand pulse waveform
            self.generate_sinc();

            % apply multi-band phase modulation to B1
            self.mb_phase_modulation();
            % GM is already set using the SINC as base class

        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s] : n_slice=%s  slice_distance=%s  n_side_lobs=%s  flip_angle=%s',...
                mfilename, self.n_slice.repr, self.slice_distance.repr, self.n_side_lobs.repr, self.flip_angle.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_sinc = uipanel(container,...
                'Title','sinc',...
                'Units','Normalized',...
                'Position',[0.00 0.00 0.50 1.00],...
                'BackgroundColor',fig_col.figureBG);
            panel_mb = uipanel(container,...
                'Title','mb',...
                'Units','Normalized',...
                'Position',[0.50 0.00 0.50 1.00],...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.sinc(self, panel_sinc);
            self.init_mb_gui(panel_mb);
        end % fcn

    end % meths

end % class
