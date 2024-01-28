classdef sms_mb_sinc < mri_rf_pulse_sim.rf_pulse.sinc & mri_rf_pulse_sim.backend.rf_pulse.sms_mb

    methods (Access = public)

        % constructor
        function self = sms_mb_sinc()
            self.generate_sms_mb_sinc();
        end % fcn

        function generate(self) % #abstract
            self.generate_sms_mb_sinc();
        end % fcn

        function generate_sms_mb_sinc(self)

            % generate SINC pulse : this is SingleBand pulse waveform
            self.generate_sinc();

            % apply multi-band phase modulation to B1
            self.mb_phase_modulation();
            % GM is already set using the SINC as base class

        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s] : n_slice=%s  slice_distance=%s  n_side_lobs=%s  flip_angle=%s',...
                mfilename, self.n_slice.repr, self.slice_distance.repr, self.n_side_lobs.repr, self.flip_angle.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n_slice self.slice_distance self.n_side_lobs, self.flip_angle],...
                [0 0.2 1 0.8]...
                );

            handles = guidata(container);
            uicontrol(container,...
                'Style'          ,'pushbutton'                  ,...
                'String'         ,'Windowing'                   ,...
                'Units'          ,'normalized'                  ,...
                'Position'       ,[0 0 1 0.2]                   ,...
                'BackgroundColor',handles.buttonBGcolor         ,...
                'Callback'       ,@self.callback_open_window_gui)
        end % fcn

    end % meths

end % class
