classdef foci_verse < mri_rf_pulse_sim.backend.rf_pulse.verse & mri_rf_pulse_sim.rf_pulse.foci

    methods (Access = public)

        % constructor
        function self = foci_verse()
            self.generate_foci_verse();
        end % fcn

        function generate(self) % #abstract
            self.generate_foci_verse();
        end % fcn

        function generate_foci_verse(self)
            self.generate_foci();
            self.verse_modulation();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.foci(self);
            txt = strrep(txt,'[foci]', sprintf('[%s::%s]',mfilename,self.type.get()));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_foci  = [0.00 0.00 0.30 1.00];
            pos_verse = [0.30 0.00 0.70 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_foci = uipanel(container,...
                'Title','foci',...
                'Units','Normalized',...
                'Position',pos_foci,...
                'BackgroundColor',fig_col.figureBG);
            panel_verse = uipanel(container,...
                'Title','verse',...
                'Units','Normalized',...
                'Position',pos_verse,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.foci(self, panel_foci);
            self.init_verse_gui(panel_verse);
        end % fcn

    end % meths

end % class
