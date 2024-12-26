classdef slr_mb_verse < mri_rf_pulse_sim.backend.rf_pulse.verse & mri_rf_pulse_sim.backend.rf_pulse.sms_mb & mri_rf_pulse_sim.rf_pulse.slr

    methods (Access = public)

        % constructor
        function self = slr_mb_verse()
            self.n_points.set(256);  % a bit more numerical precision
            self.TBWP.set(10);
            self.filter_type.value = 'ls';
            self.generate_slr_mb_verse();
        end % fcn

        function generate(self) % #abstract
            self.generate_slr_mb_verse();
        end % fcn

        function generate_slr_mb_verse(self)
            self.generate_slr();
            self.mb_phase_modulation();
            self.verse_modulation();
            self.add_gz_rewinder_verse();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.slr(self);
            txt = strrep(txt,'[slr]', sprintf('[%s::%s]',mfilename,self.type.get()));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_slr   = [0.00 0.00 0.40 1.00];
            pos_mb    = [0.40 0.00 0.20 1.00];
            pos_verse = [0.60 0.00 0.40 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_slr = uipanel(container,...
                'Title','slr',...
                'Units','Normalized',...
                'Position',pos_slr,...
                'BackgroundColor',fig_col.figureBG);
            panel_mb = uipanel(container,...
                'Title','mb',...
                'Units','Normalized',...
                'Position',pos_mb,...
                'BackgroundColor',fig_col.figureBG);
            panel_verse = uipanel(container,...
                'Title','verse',...
                'Units','Normalized',...
                'Position',pos_verse,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.slr(self, panel_slr);
            self.init_mb_gui(panel_mb);
            self.init_verse_gui(panel_verse);
        end % fcn

    end % meths

end % class
