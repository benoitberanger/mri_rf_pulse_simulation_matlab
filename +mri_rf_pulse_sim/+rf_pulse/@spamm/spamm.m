classdef spamm < mri_rf_pulse_sim.rf_pulse.binomial.binomial_rect
    % SPAMM : SPAtial Modulation of Magnetization
    % The moment of gradient between the two RECTs changes the frequency of the oscillating pattern;
    %
    % Handbook of MRI Pulse Sequences // Matt A. Bernstein, Kevin F. King, Xiaohong Joe Zhou

    properties (GetAccess = public, SetAccess = public)
        wavelength mri_rf_pulse_sim.ui_prop.scalar                         % [m]   spatial dimention of the modulation
    end % props

    properties(GetAccess = public, SetAccess = protected, Dependent)
        moment
    end % props

    methods % no attribute for dependent properties
        function value = get.moment(self)
            value = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='moment', unit='ms*mT/m', scale=1e6, ...
                value=2*pi/(self.gamma*self.wavelength) );
        end % fcn
    end % meths

    methods (Access = public)

        % constructor
        function self = spamm()
            self.wavelength = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='wavelength', value= 4e-3, unit='mm', scale=1e3);
            self.subpulse_delay.set(0.003);
            self.subpulse_width.set(0.001);
            self.slice_thickness.set(Inf);
            self.slice_thickness.visible = 'off';
            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_spamm();
        end % fcn

        function generate_spamm(self)
            self.prepare_binomial();
            self.generate_rect();
            self.make_binomial();
            self.add_spatial_modulation();
        end % fcn

        function add_spatial_modulation(self)
            coeff = str2num(self.binomial_coeff.get()); %#ok<ST2NM>

            g = [];
            for c = 1 : length(coeff)
                g = [g zeros(1,self.sample_subpulse)];
                if c ~= length(coeff)
                    g = [g ones(1,self.sample_delay)*self.moment/(self.duration*(self.sample_delay/self.n_points))];
                end
            end
            g = [0 g 0];

            self.GZ = g;
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  flip_angle=%s  %s  subpulse_width=%s  subpulse_delay=%s  wavelength=%s',...
                mfilename, self.flip_angle.repr, self.binomial_coeff.repr, self.subpulse_width.repr, self.subpulse_delay.repr, self.wavelength.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_rect       = [0.00 0.50 0.50 0.50];
            pos_wavelength = [0.00 0.00 0.50 0.50];
            pos_binomial   = [0.50 0.00 0.50 1.00];

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
            self.wavelength.add_uicontrol(container, pos_wavelength);
        end % fcn

    end % meths

end % class
