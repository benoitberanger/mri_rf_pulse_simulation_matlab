classdef binomial_rect < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % The default parameters are chosen to show how FatSat -> Water Excitation Fast works
    % At 3T, the water at dB0=0pmm is exited, but the fat at dB0=3.5ppm is not.
    %
    % Handbook of MRI Pulse Sequences // Matt A. Bernstein, Kevin F. King, Xiaohong Joe Zhou

    properties (GetAccess = public, SetAccess = public)
        flip_angle     mri_rf_pulse_sim.ui_prop.scalar                     % [deg] flip angle
        binomial_coeff mri_rf_pulse_sim.ui_prop.list                       % '1 1', '1 2 1', '1 3 3 1', ...
        subpulse_width mri_rf_pulse_sim.ui_prop.scalar                     % [s] width of the RECTS
        subpulse_delay mri_rf_pulse_sim.ui_prop.scalar                     % [s] delay between two RECTS center
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
    end % props

    methods % no attribute for dependent properties
        %%% Not sure about this definition, but it doesn't really matter : bionmial RECTs are used as non-selective
        % function value = get.bandwidth(self)
        %     coeff = self.binomial_coeff.get();
        %     value = 1 / (length(coeff)*self.subpulse_width);
        % end
        function value = get.bandwidth(self); value = 1 / self.duration; end
    end % meths

    methods (Access = public)

        % constructor
        function self = binomial_rect()
            self.slice_thickness.set(Inf); % Usually, it's a non-selective pulse
            fat_water_shift_3T = 440; % Hz
            delay_to_cancel_fat = 1 / (2*fat_water_shift_3T);
            self.flip_angle     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle'    , value= 90                , unit='°');
            self.binomial_coeff = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='binomial_coeff', value='1 1'              , items=self.getPascalTriagleCoeff());
            self.subpulse_width = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='subpulse_width', value=100e-6             , unit='µs', scale=1e6);
            self.subpulse_delay = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='subpulse_delay', value=delay_to_cancel_fat, unit='µs', scale=1e6);
            self.duration.editable = "off";           % duration is not directly an input parameter
            self.duration.value = self.getDuration(); % special duration
            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_binomial_rect();
        end % fcn

        function generate_binomial_rect(self)
            coeff = str2num(self.binomial_coeff.get()); %#ok<ST2NM>
            self.duration.value = self.getDuration(); % special duration

            sum_coeff = sum(coeff);
            weighted_coeff = coeff / sum_coeff;
            subpulse_fa = self.flip_angle * weighted_coeff;

            sample_subpulse = round((self.n_points-2) *                      self.subpulse_width /self.duration);
            sample_delay    = round((self.n_points-2) * (self.subpulse_delay-self.subpulse_width)/self.duration);
            % the -2 is to start and end with a 0;

            waveform = [];
            for c = 1 : length(coeff)
                subpulse = ones(1,sample_subpulse) / self.subpulse_width;
                subpulse = subpulse * deg2rad(subpulse_fa(c))/self.gamma;
                waveform = [waveform subpulse];
                if c ~= length(coeff)
                    waveform = [waveform zeros(1,sample_delay)];
                end
            end
            waveform = [0 waveform 0];

            self.B1 = waveform;
            self.time = linspace(0, self.duration.value, length(waveform));

            self.GZ = ones(size(self.time))*self.GZavg;

        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  flip_angle=%s  %s  subpulse_width=%s  subpulse_delay=%s',...
                mfilename, self.flip_angle.repr, self.binomial_coeff.repr, self.subpulse_width.repr, self.subpulse_delay.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.flip_angle self.subpulse_width self.subpulse_delay],...
                [0.00 0.00 0.50 1.00]...
                );
            self.binomial_coeff.add_uicontrol(...
                container,...
                [0.50 0.00 0.50 1.00]);
        end % fcn

    end % meths

    methods(Access = protected)

        function value = getDuration(self)
            coeff = str2num(self.binomial_coeff.get()); %#ok<ST2NM>
            value = length(coeff)*self.subpulse_width + (length(coeff)-1)*(self.subpulse_delay-self.subpulse_width);
        end % meths

    end % meths

    methods(Static)

        function Pcoeff = getPascalTriagleCoeff()
            n = 5; % ~~~ hard coded parameter ~~~

            Pcoeff = cell(n,1);
            Pcoeff{1} = 1;
            for m = 1:n-1
                Pcoeff{m+1} = conv(Pcoeff{m},[1 1]);
            end
            Pcoeff = cellfun(@num2str, Pcoeff, 'UniformOutput', false);
            Pcoeff = strrep(Pcoeff,'  ',' '); % dont know why there are 2 white spaces...
        end % fcn

    end % meths

end % class
