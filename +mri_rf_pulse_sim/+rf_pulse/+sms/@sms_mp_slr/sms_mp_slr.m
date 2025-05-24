classdef sms_mp_slr < ...
        mri_rf_pulse_sim.backend.rf_pulse.sms_mp & ...
        mri_rf_pulse_sim.rf_pulse.slr

    methods (Access = public)

        % constructor
        function self = sms_mp_slr()
            self.n_points.set(256);
            self.filter_type.value = 'ls';
            self.generate_sms_mp_slr();
        end % fcn

        function generate(self) % #abstract
            self.generate_sms_mp_slr();
            self.add_gz_rewinder_mp();
        end % fcn

        function generate_sms_mp_slr(self)
            self.generate_slr();
            self.make_multiphoton();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.slr(self);
            txt = strrep(txt,'[slr]', sprintf('[%s]',mfilename));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_slr = [0.00 0.00 0.50 1.00];
            pos_mp  = [0.50 0.00 0.50 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_slr = uipanel(container,...
                'Title','SLR',...
                'Units','Normalized',...
                'Position',pos_slr,...
                'BackgroundColor',fig_col.figureBG);
            panel_mp = uipanel(container,...
                'Title','mp',...
                'Units','Normalized',...
                'Position',pos_mp,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.slr(self, panel_slr);
            self.init_mp_gui(panel_mp);
        end % fcn

    end % meths

end % class
