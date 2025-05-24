classdef sms_mp_sinc < ...
        mri_rf_pulse_sim.backend.rf_pulse.sms_mp & ...
        mri_rf_pulse_sim.rf_pulse.sinc

    methods (Access = public)

        % constructor
        function self = sms_mp_sinc()
            self.n_points.set(256);
            self.n_side_lobs.set(4);
            self.generate_sms_mp_sinc();
        end % fcn

        function generate(self) % #abstract
            self.generate_sms_mp_sinc();
            self.add_gz_rewinder_mp();
        end % fcn

        function generate_sms_mp_sinc(self)
            self.generate_sinc();
            self.make_multiphoton();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.sinc(self);
            txt = strrep(txt,'[sinc]', sprintf('[%s]',mfilename));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_sinc = [0.00 0.00 0.50 1.00];
            pos_mp   = [0.50 0.00 0.50 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_sinc = uipanel(container,...
                'Title','sinc',...
                'Units','Normalized',...
                'Position',pos_sinc,...
                'BackgroundColor',fig_col.figureBG);
            panel_mp = uipanel(container,...
                'Title','mp',...
                'Units','Normalized',...
                'Position',pos_mp,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.sinc(self, panel_sinc);
            self.init_mp_gui(panel_mp);
        end % fcn

    end % meths

end % class
