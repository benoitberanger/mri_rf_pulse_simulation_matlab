classdef HSn_verse < ...
        mri_rf_pulse_sim.backend.rf_pulse.verse & ...
        mri_rf_pulse_sim.rf_pulse.HSn

    methods (Access = public)

        % constructor
        function self = HSn_verse()
            self.generate_HSn_verse();
        end % fcn

        function generate(self) % #abstract
            self.generate_HSn_verse();
        end % fcn

        function generate_HSn_verse(self)
            self.generate_HSn();
            self.verse_modulation();
            self.add_gz_rewinder_verse();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.HSn(self);
            txt = strrep(txt,'[HSn]', sprintf('[%s::%s]',mfilename,self.type.get()));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_HSn   = [0.00 0.00 0.30 1.00];
            pos_verse = [0.30 0.00 0.70 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_HSn = uipanel(container,...
                'Title','HSn',...
                'Units','Normalized',...
                'Position',pos_HSn,...
                'BackgroundColor',fig_col.figureBG);
            panel_verse = uipanel(container,...
                'Title','verse',...
                'Units','Normalized',...
                'Position',pos_verse,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.HSn(self, panel_HSn);
            self.init_verse_gui(panel_verse);
        end % fcn

    end % meths

end % class
