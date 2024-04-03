classdef fermi < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Fermi pulse is typicaly used for fat saturation.
    % Here, frequency_offcet default value is the frequency shift of the fat (lipids) at 3T.
    % Select dB0 = +3.5ppm (440Hz at 3T) -> the slice will now be "centered", its the fat that will be excited, not water.
    %
    % With this implementation the excitation bandwith only depends on the pulse duration.
    %
    % Handbook of MRI Pulse Sequences // Matt A. Bernstein, Kevin F. King, Xiaohong Joe Zhou

    properties (GetAccess = public, SetAccess = public)
        transition_factor mri_rf_pulse_sim.ui_prop.scalar                  % [] t0 = transition_factor * a, and duration = 2*t0 + 13.81*a
        flip_angle        mri_rf_pulse_sim.ui_prop.scalar                  % [deg] flip angle
        frequency_offcet  mri_rf_pulse_sim.ui_prop.scalar                  % [Hz] frequency offcet
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
        t0                                                                 % [s] pulse width
        a                                                                  % [s] transition width
        Af                                                                 % [T] amplitude
    end % props

    methods % no attribute for dependent properties
        function value = get.bandwidth(self); value = 1/self.duration * (1/(1-(1/self.transition_factor)));end % !!! wrong : very rough handmade approximation !!!
        function value = get.t0       (self); value = self.duration / (2 + 13.81/self.transition_factor);  end
        function value = get.a        (self); value = self.t0/self.transition_factor;                      end
        function value = get.Af       (self)
            value = deg2rad(self.flip_angle.get()) / ...
                (2*self.gamma * (self.t0 + self.a*log(exp(-self.t0/self.a)+1)));
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = fermi()
            self.transition_factor = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='transition_factor', value= 10           );
            self.flip_angle        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle'       , value= 90, unit='°' );
            self.frequency_offcet  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='frequency_offcet' , value=440, unit='Hz');
            self.generate_fermi();
        end % fcn

        function generate(self) % #abstract
            self.generate_fermi();
        end % fcn

        function generate_fermi(self)
            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());
            self.B1   = self.Af * exp(1j * 2*pi*self.frequency_offcet.get() * self.time) ./ ( 1 + exp((abs(self.time)-self.t0)/self.a) );
            self.GZ   = ones(size(self.time)) * self.GZavg;
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  transition_factor=%s  flip_angle=%s  frequency_offcet=%s  bandwidth=%gHz',...
                mfilename, self.transition_factor.repr, self.flip_angle.repr, self.frequency_offcet.repr, self.bandwidth);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.transition_factor self.flip_angle self.frequency_offcet],...
                [0 0 1 1]...
                );
        end % fcn

    end % meths

end % class
