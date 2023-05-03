classdef sinc < mri_rf_pulse_sim.rf_pulse.base

    properties

        n_lobs                                                             % [] number of lobs, from 1 to +Inf
        flip_angle                                                         % [deg] flip angle

    end % props


    methods

        function generate(self)
            assert( ~isempty(self.n_points), 'empty n_points' )
            assert( ~isempty(self.duration), 'empty duration' )
            assert( ~isempty(self.n_lobs  ), 'empty n_lobs'   )

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points);

            lob_size = self.duration / (2*self.n_lobs);

            self.amplitude_modulation = sinc(self.time/lob_size); % base shape
            self.amplitude_modulation = self.amplitude_modulation / trapz(self.time, self.amplitude_modulation); % normalize integral
            self.amplitude_modulation = self.amplitude_modulation * self.flip_angle * pi/180 / self.gamma; % scale integrale with flip angle
            self.frequency_modulation = zeros(size(self.time));
            self.gradient_modulation  = zeros(size(self.time));
        end

        function set.n_lobs(self, value)
            assert( ...
                isscalar(value) && isnumeric(value) && value==round(value) && value>=1, ...
                'n_lobs must be a positive integer from 1 to +Inf' ...
                )
            self.n_lobs = value;
        end

        function set.flip_angle(self, value)
            assert( ...
                isscalar(value) && isnumeric(value) && value==round(value) && value>0, ...
                'flip_angle must be positive' ...
                )
            self.flip_angle = value;
        end

    end % methods

end % class
