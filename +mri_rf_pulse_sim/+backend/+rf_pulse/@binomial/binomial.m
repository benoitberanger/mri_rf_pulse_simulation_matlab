classdef (Abstract) binomial < handle
    % Handbook of MRI Pulse Sequences // Matt A. Bernstein, Kevin F. King, Xiaohong Joe Zhou

    properties (GetAccess = public, SetAccess = public)
        binomial_coeff mri_rf_pulse_sim.ui_prop.list                       % '1 1', '1 2 1', '1 3 3 1', ...
        subpulse_width mri_rf_pulse_sim.ui_prop.scalar                     % [s] width of the RECTS
        subpulse_delay mri_rf_pulse_sim.ui_prop.scalar                     % [s] delay between two RECTS center
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        sample_subpulse
        sample_delay
    end % props

    properties (GetAccess = public, SetAccess = protected)
        data
    end % props

    methods % no attribute for dependent properties
        function value = get.sample_subpulse(self), value = round((self.n_points-2) *                      self.subpulse_width /self.get_binomial_duration()); end
        function value = get.sample_delay   (self), value = round((self.n_points-2) * (self.subpulse_delay-self.subpulse_width)/self.get_binomial_duration()); end
        % the -2 is to start and end with a 0;
    end % meths

    methods (Access=public)

        % constructor
        function self = binomial()
            self.subpulse_width = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='subpulse_width', value=  1e-3, unit='ms', scale=1e3);
            self.subpulse_delay = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='subpulse_delay', value=  3e-3, unit='ms', scale=1e3);
            self.binomial_coeff = mri_rf_pulse_sim.ui_prop.list  (parent=self, name=''              , value='1 1' , items=self.getPascalTriagleCoeff());
        end % fcn

        % this method ABOVE the generate_<pulse-name>
        function prepare_binomial(self)
            self.duration.set(self.subpulse_width);
        end % fcn

        % this method BELOW the generate_<pulse-name>
        function make_binomial(self)

            % store original pulse data
            self.data.GZavg = self.GZavg;

            % get binomial coeff and prepare wheightings
            coeff = str2num(self.binomial_coeff.get()); %#ok<ST2NM>
            sum_coeff = sum(coeff);
            weighted_coeff = coeff / sum_coeff;
            subpulse_fa = self.flip_angle * weighted_coeff;

            % copy
            subpulse_b1 = self.B1;
            subpulse_gz = self.GZ;

            % adjust and prepare new time, for interpolation
            subpulse_time = self.time;
            if subpulse_time(1) < 0
                subpulse_time = subpulse_time - subpulse_time(1);
            end
            fake_time = linspace(subpulse_time(1), subpulse_time(end), self.sample_subpulse);

            % interpolation
            subpulse_b1 = interp1(subpulse_time, subpulse_b1, fake_time, 'spline');
            subpulse_gz = interp1(subpulse_time, subpulse_gz, fake_time, 'spline');

            subpulse_b1 = subpulse_b1 / trapz(fake_time, subpulse_b1); % normalize integral

            b = [];
            g = [];
            for c = 1 : length(coeff)
                b = [b  subpulse_b1 * deg2rad(subpulse_fa(c))/self.gamma]; %#ok<*AGROW>
                g = [g +subpulse_gz];
                if c ~= length(coeff)
                    b = [b  zeros(1,self.sample_delay)                                                      ];
                    g = [g  -ones(1,self.sample_delay)*self.sample_subpulse/self.sample_delay*self.data.GZavg];
                end
            end
            b = [0 b 0];
            g = [0 g 0];

            self.B1 = b;
            self.GZ = g;

            % special duration : not directly an input parameter
            self.duration.editable = "off";
            self.duration.value    = self.get_binomial_duration();

            self.time = linspace(0, self.get_binomial_duration(), length(b));

        end % fcn

        function add_gz_rewinder_binomial(self, status)
            self.gz_rewinder.visible = "on";
            if nargin == 1, status = self.gz_rewinder.get(); end
            if ~status    , return                         , end

            n_new_points = self.sample_subpulse;
            self.time = [self.time linspace(self.time(end), self.time(end)+self.subpulse_width/2, n_new_points)];
            self.B1   = [self.B1   zeros(1,n_new_points)           ];
            self.GZ   = [self.GZ   -ones(1,n_new_points)*self.data.GZavg];
        end % fcn

        function init_binomial_gui(self, container)
            pos_width = [0.00 0.85 1.00 0.15];
            pos_delay = [0.00 0.70 1.00 0.15];
            pos_coeff = [0.00 0.00 1.00 0.70];
            self.subpulse_width.add_uicontrol(container, pos_width);
            self.subpulse_delay.add_uicontrol(container, pos_delay);
            self.binomial_coeff.add_uicontrol(container, pos_coeff);
        end % fcn

    end % meths

    methods(Access = protected)

        function value = get_binomial_duration(self)
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
