classdef sms_pins < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Norris DG, Koopmans PJ, Boyacioğlu R, Barth M. Power Independent of
    % Number of Slices (PINS) radiofrequency pulses for low-power simultaneous
    % multislice excitation. Magn Reson Med. 2011 Nov;66(5):1234-40. doi:
    % 10.1002/mrm.23152. Epub 2011 Aug 29. PMID: 22009706.

    properties (GetAccess = public, SetAccess = public)
        flip_angle        mri_rf_pulse_sim.ui_prop.scalar                  % [deg] flip angle
        N                 mri_rf_pulse_sim.ui_prop.scalar                  % [] number of subpulse in each SINC lob
        M                 mri_rf_pulse_sim.ui_prop.scalar                  % [] number of subpulse on each side (left right)
        subpulse_duration mri_rf_pulse_sim.ui_prop.scalar                  % [s] duration of each RECT subpluse
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % Hz
    end % props

    methods % no attribute for dependent properies
        function value = get.bandwidth(self); value = 1 /(self.N * self.duration / (self.M * 2 + 1)); end
    end % meths

    methods (Access = public)

        % constructor
        function self = sms_pins()
            self.flip_angle        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle'       , value= 90       , unit='°'              );
            self.N                 = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='N'                , value=  2                               );
            self.M                 = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='M'                , value=  4                               );
            self.subpulse_duration = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='subpulse_duration', value=100 * 1e-6, unit='us'  , scale=1e6);
            self.generate_PINS();
        end % fcn

        function generate(self)
            self.generate_PINS();
        end % fcn

        function generate_PINS(self)
            self.assert_nonempty_prop({'n_points', 'duration','flip_angle', 'N', 'M', 'subpulse_duration'})

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());

            % generate waveform
            waveform = (1/self.N)*self.dirac(0);
            for m = 1 : self.M.get()
                signal = 1/(pi*m) * sin(m*pi/self.N) * (self.dirac(-m/self.M*self.duration/2) + self.dirac(+m/self.M*self.duration/2));
                waveform = waveform + signal;
            end

            % scale waveform to the desired flip angle
            waveform = waveform / trapz(self.time, waveform); % normalize integral
            waveform = waveform * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle

            self.B1  = waveform;
            self.GZ  = ones(size(self.time)) * self.GZavg;

        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('rect : flip_angle=%d°  N=%d  M=%d  subpulse_duration=%gus',...
                self.flip_angle.get(), self.N.get(), self.M.get(), self.subpulse_duration.get());
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.flip_angle self.N self.M self.subpulse_duration],...
                [0 0 1 1]...
                );
        end % fcn

    end % meths

    methods (Access = private)

        function signal = dirac(self, position)
            if nargin < 2
                position = 0;
            end
            signal = zeros(size(self.time));
            [~, pos_idx] = min(abs(self.time-position));
            subpulse_points = round(self.n_points * self.subpulse_duration/self.duration);

            idx = round(pos_idx + (-subpulse_points/2 : +subpulse_points/2));
            idx(idx<=0                  ) = [];
            idx(idx >self.n_points.get()) = [];
            if ~isempty(idx)
                signal(idx) = 1;
            end
        end

    end % meths

end % class
