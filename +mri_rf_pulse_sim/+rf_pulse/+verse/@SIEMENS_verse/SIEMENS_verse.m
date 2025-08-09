classdef SIEMENS_verse < ...
        mri_rf_pulse_sim.backend.rf_pulse.verse & ...
        mri_rf_pulse_sim.rf_pulse.SIEMENS

    methods (Access = public)

        % constructor
        function self = SIEMENS_verse()
            self.generate_SIEMENS_verse();
        end % fcn

        function generate(self) % #abstract
            % SEMENS class is a bit special because of the file loading mechanism
            generate@mri_rf_pulse_sim.rf_pulse.SIEMENS(self);
            self.generate_SIEMENS_verse();
        end % fcn

        function generate_SIEMENS_verse(self)
            self.generate_SIEMENS();
            self.verse_modulation();
            self.add_gz_rewinder_verse();
        end % fcn

        function txt = summary(self) % #abstract
            txt = summary@mri_rf_pulse_sim.rf_pulse.SIEMENS(self);
            txt = strrep(txt,'[SIEMENS]', sprintf('[%s::%s]',mfilename,self.type.get()));
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_SIEMENS = [0.00 0.00 0.60 1.00];
            pos_verse   = [0.60 0.00 0.40 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_SIEMENS = uipanel(container,...
                'Title','SIEMENS',...
                'Units','Normalized',...
                'Position',pos_SIEMENS,...
                'BackgroundColor',fig_col.figureBG);
            panel_verse = uipanel(container,...
                'Title','verse',...
                'Units','Normalized',...
                'Position',pos_verse,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.SIEMENS(self, panel_SIEMENS);
            self.init_verse_gui(panel_verse);
        end % fcn

    end % meths

end % class
