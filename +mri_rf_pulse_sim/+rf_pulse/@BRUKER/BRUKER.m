classdef BRUKER < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % This class is able to load Bruker pulses, located at [mri_rf_pulse_simulation_matlab]/vendor/bruker

    properties (GetAccess = public, SetAccess = public)
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle
        pulse_list mri_rf_pulse_sim.ui_prop.list
    end % props

    properties (GetAccess = public, SetAccess = protected)
        pulse_list_struct (:,1) struct
        pulse_path        (1,:) char
        pulse_data        (1,1) struct
    end % props

    methods (Access = public)

        % constructor
        function self = BRUKER()
            location = fullfile(fileparts(mri_rf_pulse_sim.get_package_dir()), 'vendor', 'bruker');
            if ~exist(location, 'dir')
                error('No `pulse_bruker` dir at the expected location : %s', location)
            end
            pulse_list_exc = dir(fullfile(location, '**/*exc'));
            pulse_list_rfc = dir(fullfile(location, '**/*rfc'));
            pulse_list_inv = dir(fullfile(location, '**/*inv'));
            self.pulse_list_struct = [pulse_list_exc ; pulse_list_rfc ; pulse_list_inv];
            name = fullfile({self.pulse_list_struct.folder}, {self.pulse_list_struct.name})';
            name = strrep(name, fullfile(pwd, 'vendor', 'bruker'), ''); % simplify it for display
            self.pulse_list = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='pulse_list', items=name, value=name{1});
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=0, unit='°');
            self.n_points.editable = 'off'; % comes from the text file
            self.generate();
        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_BRUKER_bandwidth();
        end % fcn

        function value = get_BRUKER_bandwidth(self)
            value = self.pulse_data.SHAPE_BWFAC / self.duration;
        end % fcn

        function generate(self) %  #abstract
            % get selected pulse name
            idx = self.pulse_list.idx;
            p = self.pulse_list_struct(idx);

            % new pulse ?
            new_path = fullfile(p.folder, p.name);
            if ~strcmp(self.pulse_path, new_path)
                self.pulse_path = fullfile(p.folder, p.name);
                self.pulse_data = mri_rf_pulse_sim.load_bruker_RFpulse(self.pulse_path);
                self.flip_angle.set(self.pulse_data.SHAPE_TOTROT);
                self.n_points.set(self.pulse_data.NPOINTS);
            end

            % gen
            self.time = linspace(0, self.duration.get(), self.n_points.get());
            MAG = self.pulse_data.RF(:,1);
            MAG = MAG / trapz(self.time, MAG); % normalize integral
            MAG = MAG * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            PHA = deg2rad(self.pulse_data.RF(:,2));

            self.B1 = MAG .* exp(1j * PHA);
            self.GZ = ones(size(self.time)) * self.GZavg;
            self.add_gz_rewinder()
        end % fcn

        function txt = summary(self) %  #abstract
            txt = sprintf('<BRUKER> %s', ...
                self.pulse_list.repr);
        end % fcn

        function init_specific_gui(self, container) %  #abstract
            rect_fa        = [0.00 0.50 0.30 0.50];
            rect_pulselist = [0.30 0.00 0.70 1.00];
            self.flip_angle.add_uicontrol(container, rect_fa)
            self.pulse_list.add_uicontrol(container, rect_pulselist)
        end % fcn

    end % meths

end % class