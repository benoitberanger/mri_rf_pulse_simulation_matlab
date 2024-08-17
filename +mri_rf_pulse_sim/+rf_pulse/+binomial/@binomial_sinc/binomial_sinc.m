classdef binomial_sinc < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Handbook of MRI Pulse Sequences // Matt A. Bernstein, Kevin F. King, Xiaohong Joe Zhou

    properties (GetAccess = public, SetAccess = public)
        n_side_lobs    mri_rf_pulse_sim.ui_prop.scalar                     % [] number of side lobs, from 1 to +Inf
        flip_angle     mri_rf_pulse_sim.ui_prop.scalar                     % [deg] flip angle
        binomial_coeff mri_rf_pulse_sim.ui_prop.list                       % '1 1', '1 2 1', '1 3 3 1', ...
        subpulse_width mri_rf_pulse_sim.ui_prop.scalar                     % [s] width of the RECTS
        subpulse_delay mri_rf_pulse_sim.ui_prop.scalar                     % [s] delay between two RECTS center

        window         mri_rf_pulse_sim.ui_prop.window                     % apply a window to the base Sinc waveform
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
    end % props

    methods % no attribute for dependent properties
        function value = get.bandwidth(self)
            value = (2*self.n_side_lobs) / self.subpulse_width;
        end% % fcn
    end % meths

    methods (Access = public)

        % constructor
        function self = binomial_sinc()
            self.n_side_lobs    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_side_lobs'   , value=  2                         );
            self.flip_angle     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle'    , value= 90   , unit='°'            );
            self.subpulse_width = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='subpulse_width', value=  1e-3, unit='ms', scale=1e3);
            self.subpulse_delay = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='subpulse_delay', value=  2e-3, unit='ms', scale=1e3);
            self.binomial_coeff = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='binomial_coeff', value='1 1' , items=self.getPascalTriagleCoeff());
            self.window         = mri_rf_pulse_sim.ui_prop.window(parent=self, name='apodization'   , value=''                          );
            self.duration.editable = "off";           % duration is not directly an input parameter
            self.duration.value = self.getDuration(); % special duration
            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_binomial_sinc();
            self.add_gz_rewinder();
        end % fcn

        function generate_binomial_sinc(self)
            coeff = str2num(self.binomial_coeff.get()); %#ok<ST2NM>
            self.duration.value = self.getDuration(); % special duration

            sum_coeff = sum(coeff);
            weighted_coeff = coeff / sum_coeff;
            subpulse_fa = self.flip_angle * weighted_coeff;

            sample_subpulse = round((self.n_points-2) *                      self.subpulse_width /self.duration);
            sample_delay    = round((self.n_points-2) * (self.subpulse_delay-self.subpulse_width)/self.duration);
            % the -2 is to start and end with a 0;

            lob_size = 1/self.bandwidth;
            subpulse_time = linspace(-self.subpulse_width/2, +self.subpulse_width/2, sample_subpulse);

            waveform = [];
            grad     = [];
            for c = 1 : length(coeff)
                subpulse = Sinc(subpulse_time/lob_size); % base shape
                subpulse = subpulse .* self.window.getShape(subpulse_time); % windowing
                subpulse = subpulse / trapz(subpulse_time, subpulse); % normalize integral
                subpulse = subpulse * deg2rad(subpulse_fa(c))/self.gamma;
                waveform = [waveform  subpulse               ]; %#ok<*AGROW>
                grad     = [grad     +ones(1,sample_subpulse)];
                if c ~= length(coeff)
                    waveform = [waveform  zeros(1,sample_delay)                             ];
                    grad     = [grad      -ones(1,sample_delay)*sample_subpulse/sample_delay];
                end
            end
            waveform = [0 waveform 0];
            grad     = [0 grad     0];

            self.B1 = waveform;
            self.time = linspace(0, self.duration.value, length(waveform));

            self.GZ = grad*self.GZavg;

        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  n_side_lobs=%s  flip_angle=%s  %s  subpulse_width=%s  subpulse_delay=%s',...
                mfilename, self.n_side_lobs.repr, self.flip_angle.repr, self.binomial_coeff.repr, self.subpulse_width.repr, self.subpulse_delay.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n_side_lobs self.flip_angle self.subpulse_width self.subpulse_delay],...
                [0.00 0.00 0.60 1.00]...
                );

            self.binomial_coeff.add_uicontrol(...
                container,...
                [0.60 0.20 0.40 0.80]);

            self.window.add_uicontrol( ...
                container, ...
                [0.60 0.00 0.40 0.20])
        end % fcn

        function add_gz_rewinder(self, status)
            self.gz_rewinder.visible = "on";
            if nargin == 1, status = self.gz_rewinder.get(); end
            if ~status    , return                         , end

            sample_subpulse = round((self.n_points-2) * self.subpulse_width /self.duration);
            n_new_points = sample_subpulse;
            self.time = [self.time linspace(self.time(end), self.time(end)+self.subpulse_width/2, n_new_points)];
            self.B1   = [self.B1   zeros(1,n_new_points)           ];
            self.GZ   = [self.GZ   -ones(1,n_new_points)*self.GZavg];
        end % fcn

    end % meths

    methods(Access = protected)

        function value = getDuration(self)
            coeff = str2num(self.binomial_coeff.get()); %#ok<ST2NM>
            value = length(coeff)*self.subpulse_width + (length(coeff)-1)*(self.subpulse_delay-self.subpulse_width);
        end % fcn

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

function y = Sinc(x)
i    = find(x==0);        % identify the zeros
x(i) = 1;                 % fix the DIVIDED_BY_ZERO problem
y    = sin(pi*x)./(pi*x); % generate the Sinc curve
y(i) = 1;                 % fix the DIVIDED_BY_ZERO problem
end % fcn
