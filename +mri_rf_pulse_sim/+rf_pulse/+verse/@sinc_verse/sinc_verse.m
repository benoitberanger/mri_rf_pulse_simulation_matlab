classdef sinc_verse < mri_rf_pulse_sim.rf_pulse.sinc & mri_rf_pulse_sim.backend.rf_pulse.verse

    methods (Access = public)

        % constructor
        function self = sinc_verse()
            self.generate_sinc_verse();
        end % fcn

        function generate(self) % #abstract
            self.generate_sinc_verse();
        end % fcn

        function generate_sinc_verse(self)
            self.generate_sinc();
            self.verse_rand();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.sinc(self);
            txt = strrep(txt,'[sinc]', sprintf('[%s::rand]',mfilename));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_sinc = uipanel(container,...
                'Title','sinc',...
                'Units','Normalized',...
                'Position',[0.00 0.00 0.50 1.00],...
                'BackgroundColor',fig_col.figureBG);
            panel_verse = uipanel(container,...
                'Title','verse',...
                'Units','Normalized',...
                'Position',[0.50 0.00 0.50 1.00],...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.sinc(self, panel_sinc);
            self.init_verse_gui(panel_verse);
        end % fcn

    end % meths

end % class
