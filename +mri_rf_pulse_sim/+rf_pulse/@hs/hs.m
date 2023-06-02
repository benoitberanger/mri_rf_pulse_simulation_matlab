classdef hs < mri_rf_pulse_sim.rf_pulse.base

    properties (GetAccess = public, SetAccess = public, SetObservable, AbortSet)

        A0   mri_rf_pulse_sim.ui_prop.scalar                               % [T] B1max
        beta mri_rf_pulse_sim.ui_prop.scalar                               % ?
        mu   mri_rf_pulse_sim.ui_prop.scalar                               % ?
        gz   mri_rf_pulse_sim.ui_prop.scalar                               % [T/m] slice/slab selection gradient

    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth (1,1) double                                             % Hz
    end % props

    methods % no attribute for dependent properies
        function value = get.bandwidth(self)
            value = self.beta.value * self.mu.value  / pi;
        end% % fcn
    end % meths

    methods (Access = public)

        % constructor
        function self = hs()
            self.A0          = mri_rf_pulse_sim.ui_prop.scalar('A0'  ,  100 * 1e-6, 'µT'  , 1e6);
            self.beta        = mri_rf_pulse_sim.ui_prop.scalar('beta', 5000                    );
            self.mu          = mri_rf_pulse_sim.ui_prop.scalar('mu'  ,    0.5                  );
            self.gz          = mri_rf_pulse_sim.ui_prop.scalar('gz'  ,   20 * 1e-3, 'mT/m', 1e3);
            self.A0  .parent = self;
            self.beta.parent = self;
            self.mu  .parent = self;
            self.gz  .parent = self;
            self.generate();
        end % fcn

        % generate time, AM, FM, GM
        function generate(self)
            self.assert_nonempty_prop({'A0', 'beta', 'mu', 'gz'})

            self.time = linspace(-self.duration.value/2, +self.duration.value/2, self.n_points.value);

            self.amplitude_modulation = self.A0.value*sech(self.beta.value * self.time);
            self.frequency_modulation = -self.mu.value * self.beta.value * tanh(self.beta.value * self.time);
            self. gradient_modulation = ones(size(self.time)) * self.gz.value;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('hs : BW=%gHz  A0=%gµT  beta=%g  mu=%g  gz=%gmT/m',...
                self.bandwidth, self.A0.value*self.A0.scale, self.beta.value, self.mu.value, self.gz.value*self.gz.scale);
        end % fcn

    end % meths

    methods (Access = {?mri_rf_pulse_sim.pulse_definition})

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.A0, self.beta, self.mu, self.gz]...
                );
        end % fcn

    end % meths

end % class
