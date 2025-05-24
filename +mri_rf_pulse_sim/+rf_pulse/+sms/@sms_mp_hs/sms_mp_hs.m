classdef sms_mp_hs < ...
        mri_rf_pulse_sim.backend.rf_pulse.sms_mp & ...
        mri_rf_pulse_sim.rf_pulse.hs

    methods (Access = public)

        % constructor
        function self = sms_mp_hs()
            self.generate_sms_mp_hs();
        end % fcn

        function generate(self) % #abstract
            self.generate_sms_mp_hs();
            self.add_gz_rewinder_mp();
        end % fcn

        function generate_sms_mp_hs(self)
            self.generate_hs();
            self.make_multiphoton();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.hs(self);
            txt = strrep(txt,'[hs]', sprintf('[%s]',mfilename));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_hs = [0.00 0.00 0.50 1.00];
            pos_mp   = [0.50 0.00 0.50 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_hs = uipanel(container,...
                'Title','hs',...
                'Units','Normalized',...
                'Position',pos_hs,...
                'BackgroundColor',fig_col.figureBG);
            panel_mp = uipanel(container,...
                'Title','mp',...
                'Units','Normalized',...
                'Position',pos_mp,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.hs(self, panel_hs);
            self.init_mp_gui(panel_mp);
        end % fcn

    end % meths

end % class
