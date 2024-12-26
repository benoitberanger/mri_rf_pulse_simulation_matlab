classdef hs_excitation_mb_verse < mri_rf_pulse_sim.backend.rf_pulse.verse & mri_rf_pulse_sim.backend.rf_pulse.sms_mb & mri_rf_pulse_sim.rf_pulse.hs_excitation

    methods (Access = public)

        % constructor
        function self = hs_excitation_mb_verse()
            self.n_points.set(512); % need a bit more numerical precision
            self.generate_hs_excitation_mb_verse();
        end % fcn

        function generate(self) % #abstract
            self.generate_hs_excitation_mb_verse();
        end % fcn

        function generate_hs_excitation_mb_verse(self)
            self.generate_hs_excitation();
            self.mb_phase_modulation();
            self.verse_modulation();
            self.add_gz_rewinder_verse();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.hs_excitation(self);
            txt = strrep(txt,'[hs_excitation]', sprintf('[%s::%s]',mfilename,self.type.get()));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_hse  = [0.00 0.00 0.20 1.00];
            pos_mb    = [0.20 0.00 0.30 1.00];
            pos_verse = [0.50 0.00 0.50 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_hse = uipanel(container,...
                'Title','hs_ex',...
                'Units','Normalized',...
                'Position',pos_hse,...
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

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.hs_excitation(self, panel_hse);
            self.init_mb_gui(panel_mb);
            self.init_verse_gui(panel_verse);
        end % fcn

    end % meths

end % class
