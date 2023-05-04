classdef (Abstract) base < handle

    properties (GetAccess = public, SetAccess = public)

        n_points              (1,1) double {mustBePositive, mustBeInteger} = 512                               % []  number of points defining the pulse
        duration              (1,1) double {mustBePositive}                =   5 * 1e-3                        % [s] pulse duration

        time                  (1,:) double                                                                     % [ms] time vector

        amplitude_modulation  (1,:) double                                                                     % [T]
        frequency_modulation  (1,:) double                                                                     % [Hz]
        gradient_modulation   (1,:) double                                                                     % [T/m]

        B0                    (1,1) double {mustBePositive}                =   2.89                            % [T] static magnetic field strength
        gamma                 (1,1) double {mustBePositive}                = mri_rf_pulse_sim.get_gamma('1H')  % [rad/T/s] gyromagnetic ration

    end % props

    methods (Access = public)

        function plot(self)
            self.assert_nonempty_prop({'time', 'amplitude_modulation', 'frequency_modulation', 'gradient_modulation'})

            obj_def = strsplit(class(self), '.');
            figure('NumberTitle','off','Name',obj_def{end});

            a(1) = subplot(6,1,[1 2]);
            plot(a(1), self.time*1e3, self.amplitude_modulation*1e6)
            a(1).XTickLabel = {};
            a(1).YLabel.String = 'a.m. (µT)';

            a(2) = subplot(6,1,[3 4]);
            plot(a(2), self.time*1e3, self.frequency_modulation)
            a(2).XTickLabel = {};
            a(2).YLabel.String = 'f.m. (Hz)';

            a(3) = subplot(6,1,[5 6]);
            plot(a(3), self.time*1e3, self.gradient_modulation*1e3)
            a(3).XLabel.String = 'time (ms)';
            a(3).YLabel.String = 'g.m. (mT/m)';
        end

    end % meths

    methods (Access = protected)

        function assert_nonempty_prop(self, prop_list)
            assert(ischar(prop_list) || iscellstr(prop_list)) %#ok<ISCLSTR>

            prop_list = cellstr(prop_list); % force cellstr

            for p = 1 : numel(prop_list)
                assert( ~isempty(self.(prop_list{p})), 'empty %s', prop_list{p} )
            end
        end % fcn

    end % meths

end % class
