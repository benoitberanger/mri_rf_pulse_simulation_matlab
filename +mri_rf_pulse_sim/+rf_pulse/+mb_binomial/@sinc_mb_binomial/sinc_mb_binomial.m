classdef sinc_mb_binomial < ...
        mri_rf_pulse_sim.backend.rf_pulse.binomial & ...
        mri_rf_pulse_sim.backend.rf_pulse.sms_mb   & ...
        mri_rf_pulse_sim.rf_pulse.sinc

    methods (Access = public)

        % constructor
        function self = sinc_mb_binomial()
            self.n_points.set(512);  % a bit more numerical precision
            self.n_side_lobs.set(5); % set a very high TimeBandwidth-Product
            self.generate_sinc_mb_binomial();
        end % fcn

        function generate(self) % #abstract
            self.generate_sinc_mb_binomial();
        end % fcn

        function generate_sinc_mb_binomial(self)
            self.prepare_binomial();
            self.generate_sinc();
            self.mb_phase_modulation();
            self.make_binomial();
            self.add_gz_rewinder_binomial();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.sinc(self);
            txt = strrep(txt,'[sinc]', sprintf('[%s::%s]',mfilename,self.binomial_coeff.repr));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_sinc     = [0.00 0.00 0.33 1.00];
            pos_mb       = [0.33 0.00 0.33 1.00];
            pos_binomial = [0.66 0.00 0.33 1.00];

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
            panel_binomial = uipanel(container,...
                'Title','binomial',...
                'Units','Normalized',...
                'Position',pos_binomial,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.sinc(self, panel_sinc);
            self.init_mb_gui(panel_mb);
            self.init_binomial_gui(panel_binomial);
        end % fcn

    end % meths

end % class
