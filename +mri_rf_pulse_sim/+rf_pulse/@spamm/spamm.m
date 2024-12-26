classdef spamm < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % SPAMM : SPAtial Modulation of Magnetization
    % The moment of gradient between the two RECTs changes the frequency of the oscillating pattern;
    %
    % Handbook of MRI Pulse Sequences // Matt A. Bernstein, Kevin F. King, Xiaohong Joe Zhou

    properties (GetAccess = public, SetAccess = public)
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle
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
            self.n_points.value = 128;
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=90   , unit='°'            );
            self.wavelength = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='wavelength', value= 4e-3, unit='mm', scale=1e3);
            self.slice_thickness.set(Inf);
            self.slice_thickness.visible = 'off';
            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_spamm();
        end % fcn

        function generate_spamm(self)
            proportions          = struct;
            proportions.subpulse = 0.20;
            proportions.tag      = 0.40;
            proportions.remain   = 1 - proportions.subpulse*2 - proportions.tag;
            proportions.delay    = proportions.remain / 4;

            time_subpulse = linspace(0, self.duration*proportions.subpulse, round(self.n_points*proportions.subpulse));
            time_tag      = linspace(0, self.duration*proportions.tag     , round(self.n_points*proportions.tag ));
            time_delay    = linspace(0, self.duration*proportions.delay   , round(self.n_points*proportions.delay   ));

            subpulse = ones(size(time_subpulse)); % base shape
            subpulse = subpulse / trapz(time_subpulse, subpulse); % normalize integral
            subpulse = subpulse * deg2rad(self.flip_angle.get()/2) / self.gamma; % scale integrale with flip angle
            delay    = zeros(size(time_delay));
            tag      = ones(size(time_tag)) * self.moment / (self.duration*proportions.tag);

            self.B1 = delay;
            self.GZ = delay;

            self.B1 = [self.B1 subpulse];
            self.GZ = [self.GZ zeros(size(subpulse))];

            self.B1 = [self.B1 delay];
            self.GZ = [self.GZ delay];

            self.B1 = [self.B1 zeros(size(tag))];
            self.GZ = [self.GZ tag];

            self.B1 = [self.B1 delay];
            self.GZ = [self.GZ delay];

            self.B1 = [self.B1 subpulse];
            self.GZ = [self.GZ zeros(size(subpulse))];

            self.B1 = [self.B1 delay];
            self.GZ = [self.GZ delay];

            self.time = linspace(0, self.duration.get(), length(self.B1)); % rounding errors: maybe we miss 1 point
        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_spamm_bandwidth();
        end % fcn

        function value = get_spamm_bandwidth(self)
            value = 1 / self.duration; % same as RECT (like all binomial pulses base waveform)
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  flip_angle=%s  wavelength=%s',...
                mfilename, self.flip_angle.repr, self.wavelength.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.flip_angle self.wavelength],...
                [0 0 1 1]...
                );
        end % fcn

    end % meths

end % class
