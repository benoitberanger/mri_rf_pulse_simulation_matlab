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
        use_blip          mri_rf_pulse_sim.ui_prop.bool                    % use blip gradients between subpulse, or sue continuous slice gradient
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        slice_distance                                                     % [m]
        bandwidth                                                          % [Hz]
        subpulse_number                                                    % []
        blip_duration                                                      % [s]
    end % props

    methods % no attribute for dependent properies

        function value = get.slice_distance(self)
            value = self.N * self.slice_thickness;
        end

        function value = get.bandwidth(self)
            value = self.subpulse_number /(self.N * self.duration);
        end

        function value = get.subpulse_number(self)
            value = 2 * self.M + 1;
        end

        function value = get.blip_duration(self)
            value = self.duration / (self.subpulse_number-1) - self.subpulse_duration;
        end

    end % meths

    methods (Access = public)

        % constructor
        function self = sms_pins()
            self.flip_angle        = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle'       , value= 90       , unit='°'                  );
            self.N                 = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='N'                , value=  2                                   );
            self.M                 = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='M'                , value= 10                                   );
            self.subpulse_duration = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='subpulse_duration', value=100 * 1e-6, unit='us'      , scale=1e6);
            self.use_blip          = mri_rf_pulse_sim.ui_prop.bool  (parent=self, name='use_blip'         , value=true      , text='use_blip'           );
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

            if self.use_blip.get()
                gradientshape = zeros(size(self.time));
                for m = 1 : self.M.get()
                    signal = (self.blip(-(m-0.5)/self.M*self.duration/2) + self.blip(+(m-0.5)/self.M*self.duration/2));
                    gradientshape = gradientshape + signal;
                end
                self.GZ = self.GZavg / mean(gradientshape) * gradientshape; % scale gradient -> for slice thickness
            else
                self.GZ = ones(size(self.time)) * self.GZavg; % scale gradient -> for slice thickness
            end

        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('rect : flip_angle=%d°  N=%d  M=%d  subpulse_duration=%gus',...
                self.flip_angle.get(), self.N.get(), self.M.get(), self.subpulse_duration.get());
        end % fcn

        function init_specific_gui(self, container)
            self.use_blip.add_uicontrol(...
                container,...
                [0.0 0.0 1.0 0.2]...
                );
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.flip_angle self.N self.M self.subpulse_duration],...
                [0.0 0.2 1.0 0.8]...
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

            idx = round(pos_idx + (1:subpulse_points) - subpulse_points/2);
            idx(idx<=0                  ) = [];
            idx(idx >self.n_points.get()) = [];
            if ~isempty(idx)
                signal(idx) = 1;
            end
        end

        function signal = blip(self, position)
            if nargin < 2
                position = 0;
            end

            signal = zeros(size(self.time));
            [~, pos_idx] = min(abs(self.time-position));
            blip_points = round(self.n_points * self.blip_duration/self.duration);

            idx = round(pos_idx + (1:blip_points) - blip_points/2);

            shape = linspace(0,blip_points/2,blip_points/2);
            if mod(blip_points,2) == 0
                shape = [shape fliplr(shape)];
            else
                shape = [shape blip_points/2 fliplr(shape)];
            end
            shape = shape / (blip_points/2);

            signal(idx) = shape;
        end

    end % meths

end % class
