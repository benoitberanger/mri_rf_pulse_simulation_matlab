classdef sms_mb_sinc < mri_rf_pulse_sim.backend.rf_pulse.sms_mb & mri_rf_pulse_sim.rf_pulse.sinc

    methods (Access = public)

        % constructor
        function self = sms_mb_sinc()
            self.generate_sms_mb_sinc();
        end % fcn

        function generate(self) % #abstract
            self.generate_sms_mb_sinc();
            self.add_gz_rewinder();
        end % fcn

        function generate_sms_mb_sinc(self)
            self.generate_sinc();
            self.mb_phase_modulation(); % apply multi-band phase modulation to B1
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.sinc(self);
            txt = strrep(txt,'[sinc]', sprintf('[%s]',mfilename));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_sinc = [0.00 0.00 0.50 1.00];
            pos_mb   = [0.50 0.00 0.50 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_sinc = uipanel(container,...
                'Title','sinc',...
                'Units','Normalized',...
                'Position',pos_sinc,...
                'BackgroundColor',fig_col.figureBG);
            panel_mb = uipanel(container,...
                'Title','mb',...
                'Units','Normalized',...
                'Position',pos_mb,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.sinc(self, panel_sinc);
            self.init_mb_gui(panel_mb);
        end % fcn

    end % meths

end % class
