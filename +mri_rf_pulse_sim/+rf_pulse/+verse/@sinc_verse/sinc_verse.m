classdef sinc_verse < mri_rf_pulse_sim.backend.rf_pulse.verse & mri_rf_pulse_sim.rf_pulse.sinc

    methods (Access = public)

        % constructor
        function self = sinc_verse()
            self.n_points.set(256);  % a bit more numerical precision
            self.n_side_lobs.set(5); % set a very high TimeBandwidth-Product
            self.generate_sinc_verse();
        end % fcn

        function generate(self) % #abstract
            self.generate_sinc_verse();
        end % fcn

        function generate_sinc_verse(self)
            self.generate_sinc();
            self.verse_modulation();
            self.add_gz_rewinder_verse();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.sinc(self);
            txt = strrep(txt,'[sinc]', sprintf('[%s::%s]',mfilename,self.type.get()));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_sinc  = [0.00 0.00 0.30 1.00];
            pos_verse = [0.30 0.00 0.70 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_sinc = uipanel(container,...
                'Title','sinc',...
                'Units','Normalized',...
                'Position',pos_sinc,...
                'BackgroundColor',fig_col.figureBG);
            panel_verse = uipanel(container,...
                'Title','verse',...
                'Units','Normalized',...
                'Position',pos_verse,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.sinc(self, panel_sinc);
            self.init_verse_gui(panel_verse);
        end % fcn

    end % meths

end % class
