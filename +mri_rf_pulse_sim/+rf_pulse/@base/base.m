classdef (Abstract) base < handle

    properties

        n_points                                                           % []  number of points defining the pulse
        duration                                                           % [s] pulse duration

        time                                                               % [s] time vector

        amplitude_modulation                                               % [T]
        frequency_modulation                                               % [Hz]
        gradient_modulation                                                % [T/m]

        B0                                                                 % [T] static magnetic field strength
        gamma                                                              % [rad/T/s] gyromagnetic ration

    end % props

    methods

        function plot(self)
            assert( ~isempty(self.time), 'empty time'                 )
            assert( ~isempty(self.time), 'empty amplitude_modulation' )
            assert( ~isempty(self.time), 'empty frequency_modulation' )
            assert( ~isempty(self.time), 'empty gradient_modulation'  )

            obj_def = strsplit(class(self), '.');
            figure('NumberTitle','off','Name',obj_def{end});

            a(1) = subplot(6,1,[1 2]);
            plot(a(1), self.time, self.amplitude_modulation)

            a(2) = subplot(6,1,[3 4]);
            plot(a(2), self.time, self.frequency_modulation)

            a(3) = subplot(6,1,[5 6]);
            plot(a(3), self.time, self.gradient_modulation)

        end

        function set.n_points(self, value)
            assert( ...
                isscalar(value) && isnumeric(value) && value==round(value) && value>0, ...
                'n_points must be a positive integer' ...
                )
            self.n_points = value;
        end

        function set.duration(self, value)
            assert( ...
                isscalar(value) && isnumeric(value) && value>0, ...
                'duration must be positive' ...
                )
            self.duration = value;
        end

        function set.B0(self, value)
            assert( ...
                isscalar(value) && isnumeric(value) && value>0, ...
                'B0 must be positive' ...
                )
            self.B0 = value;
        end

        function set.gamma(self, value)
            assert( ...
                isscalar(value) && isnumeric(value) && value>0, ...
                'gamma must be positive' ...
                )
            self.gamma = value;
        end

    end % methods

end % class
