classdef sms_mb_hs < mri_rf_pulse_sim.backend.rf_pulse.sms_mb & mri_rf_pulse_sim.rf_pulse.hs

    methods (Access = public)

        % constructor
        function self = sms_mb_hs()
            self.generate_sms_mb_hs();
        end % fcn

        function generate(self) % #abstract
            self.generate_sms_mb_hs();
        end % fcn

        function generate_sms_mb_hs(self)
            self.mb_phase_modulation(); % apply multi-band phase modulation to B1
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.hs(self);
            txt = strrep(txt,'[hs]', sprintf('[%s]',mfilename));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_hs = uipanel(container,...
                'Title','hs',...
                'Units','Normalized',...
                'Position',[0.00 0.00 0.50 1.00],...
                'BackgroundColor',fig_col.figureBG);
            panel_mb = uipanel(container,...
                'Title','mb',...
                'Units','Normalized',...
                'Position',[0.50 0.00 0.50 1.00],...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.hs(self, panel_hs);
            self.init_mb_gui(panel_mb);
        end % fcn

    end % meths

end % class
