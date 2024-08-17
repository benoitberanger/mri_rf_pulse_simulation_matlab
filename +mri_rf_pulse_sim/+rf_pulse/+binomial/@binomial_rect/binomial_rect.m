classdef binomial_rect < mri_rf_pulse_sim.backend.rf_pulse.binomial & mri_rf_pulse_sim.rf_pulse.rect
    % The default parameters are chosen to show how FatSat -> Water Excitation Fast works
    % At 3T, the water at dB0=0pmm is exited, but the fat at dB0=3.5ppm is not.
    %
    % Handbook of MRI Pulse Sequences // Matt A. Bernstein, Kevin F. King, Xiaohong Joe Zhou

    methods (Access = public)

        % constructor
        function self = binomial_rect()
            self.n_points.set(128);
            self.slice_thickness.set(Inf); % Usually, it's a non-selective pulse
            fat_water_shift_3T = 440; % Hz
            delay_to_cancel_fat = 1 / (2*fat_water_shift_3T);
            self.subpulse_delay.set(delay_to_cancel_fat);
            self.subpulse_width.set(500e-6);
            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_binomial_rect();
        end % fcn

        function generate_binomial_rect(self)
            self.prepare_binomial();
            self.generate_rect();
            self.make_binomial();
            self.add_gz_rewinder_binomial();
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s] flip_angle=%s  %s  subpulse_width=%s  subpulse_delay=%s',...
                mfilename, self.flip_angle.repr, self.binomial_coeff.repr, self.subpulse_width.repr, self.subpulse_delay.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_rect     = [0.00 0.00 0.50 1.00];
            pos_binomial = [0.50 0.00 0.50 1.00];

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            panel_rect = uipanel(container,...
                'Title','',...
                'Units','Normalized',...
                'Position',pos_rect,...
                'BackgroundColor',fig_col.figureBG);
            panel_binomial = uipanel(container,...
                'Title','',...
                'Units','Normalized',...
                'Position',pos_binomial,...
                'BackgroundColor',fig_col.figureBG);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.rect(self, panel_rect);
            self.init_binomial_gui(panel_binomial);
        end % fcn

    end % meths

end % class
