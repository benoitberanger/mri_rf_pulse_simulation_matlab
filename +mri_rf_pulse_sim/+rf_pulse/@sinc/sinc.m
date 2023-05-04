classdef sinc < mri_rf_pulse_sim.rf_pulse.base

    properties (GetAccess = public, SetAccess = public)

        n_lobs     (1,1) double {mustBePositive, mustBeInteger}            =  7         % [] number of lobs, from 1 to +Inf
        flip_angle (1,1) double {mustBePositive}                           = 90         % [deg] flip angle
        gz         (1,1) double                                            = 10 * 1e-3  % [T/m] slice/slab selection gradient

    end % props


    methods (Access = public)

        function generate(self)
            self.assert_nonempty_prop({'n_points', 'duration', 'n_lobs'})

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points);

            lob_size = self.duration / (2*self.n_lobs);

            self.amplitude_modulation = sinc(self.time/lob_size); % base shape
            self.amplitude_modulation = self.amplitude_modulation / trapz(self.time, self.amplitude_modulation); % normalize integral
            self.amplitude_modulation = self.amplitude_modulation * deg2rad(self.flip_angle) / self.gamma; % scale integrale with flip angle
            self.frequency_modulation = zeros(size(self.time));
            self.gradient_modulation  = ones(size(self.time)) * self.gz;
        end % fcn

    end % meths

end % class
