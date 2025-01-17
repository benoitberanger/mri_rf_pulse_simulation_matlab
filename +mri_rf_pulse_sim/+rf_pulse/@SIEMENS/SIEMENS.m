classdef SIEMENS < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % This class is able to load Siemens pulses, located at [mri_rf_pulse_simulation_matlab]/vendor/siemens

    properties (GetAccess = public, SetAccess = public)
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle
        file_list  mri_rf_pulse_sim.ui_prop.list                           % list of files on vendor/siemens
        pulse_list mri_rf_pulse_sim.ui_prop.list                           % list of pulses in the selected file
    end % props

    properties (GetAccess = public, SetAccess = protected)
        file_list_struct  (:,1) struct
        file_path         (1,:) char
        file_info_struct  (1,1) struct
        pulse_list_struct (:,1) struct
        pulse_name        (1,:) char
        pulse_data        (1,1) struct
        button                  matlab.ui.control.UIControl
    end % props

    methods (Access = public)

        % constructor
        function self = SIEMENS()
            % siemens pulse in the correct dir ?
            location = fullfile(fileparts(mri_rf_pulse_sim.get_package_dir()), 'vendor', 'siemens');
            assert(exist(location, 'dir'), 'No `vendor/siemens` dir at the expected location : %s', location)

            % fetch all files
            self.file_list_struct = dir(fullfile(location, '**/*.dat'));
            assert(~isempty(self.file_list_struct), 'no .dat file found in %s', location)

            % prepare their name
            list_file_name = fullfile({self.file_list_struct.folder}, {self.file_list_struct.name})';
            list_file_name = strrep(list_file_name, fullfile(fileparts(mri_rf_pulse_sim.get_package_dir()), 'vendor', 'siemens', filesep), ''); % simplify it for display
            self.file_path = fullfile({self.file_list_struct(1).folder}, {self.file_list_struct(1).name});

            % load first file found
            list_pulse_name = self.load_file(fullfile(self.file_list_struct(1).folder, self.file_list_struct(1).name));

            % classic constructor steps
            self.file_list  = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='file_list' , items=string(list_file_name) , value=list_file_name {1});
            self.pulse_list = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='pulse_list', items=string(list_pulse_name), value=list_pulse_name{1});
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=90             , unit='°'                );
            self.n_points.editable = "off";
            self.generate_SIEMENS();
            self.add_gz_rewinder();
        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_SIEMENS_bandwidth();
        end % fcn

        function value = get_SIEMENS_bandwidth(self)
            % refgrad => Amplitude of slice selection gradient required to excite a 10mm thick slice
            % also, gamma (in siemens doc) is in Hz/T, so the 2pi factor is not present bellow because my gamma is in rad/T
            value = self.pulse_data.refgrad/1000 * self.gamma * 0.010 * (0.001/self.duration);
        end % fcn

        function generate(self) %  #abstract
            self.generate_SIEMENS();
            self.add_gz_rewinder();
        end % fcn

        function generate_SIEMENS(self)

            % get selected file name
            idx_file      = self.file_list.idx;
            selected_file = self.file_list_struct(idx_file);
            new_file_path = fullfile(selected_file.folder, selected_file.name);

            if ~strcmp(self.file_path, new_file_path) % new file ?
                self.load_file(fullfile(self.file_list_struct(idx_file).folder, self.file_list_struct(idx_file).name));

            else % new pulse ?
                % get selected pulse name
                idx_pulse      = self.pulse_list.idx;
                selected_pulse = self.pulse_list.value;

                % new pulse ?
                if ~strcmp(self.pulse_name, selected_pulse)
                    self.pulse_name = selected_pulse;
                    self.pulse_data = self.pulse_list_struct(idx_pulse);
                end

            end

            % the reference pulse for scaling is a RECT of 1ms and 180°
            rect = mri_rf_pulse_sim.rf_pulse.rect();
            rect.gamma = self.gamma; % make sure to use the same nucleus
            rect.duration.set(0.001);
            rect.flip_angle.set(180);
            rect.generate();
            reference_B1 = max(rect.mag);

            % gen
            self.n_points.set(self.pulse_data.samples);
            self.time = linspace(0, self.duration.get(), self.n_points.get());
            MAG = self.pulse_data.mag * reference_B1*(self.pulse_data.samples/self.pulse_data.amplint) * (self.flip_angle/180) * (0.001/self.duration);
            self.B1 = MAG .* exp(1j * self.pulse_data.pha);

            self.GZ = ones(size(self.time)) * self.GZavg;

        end % fcn

        function txt = summary(self) %  #abstract
            txt = sprintf('<SIEMENS> %s', ...
                self.pulse_list.repr);
        end % fcn

        function init_specific_gui(self, container) %  #abstract
            rect_file      = [0.00 0.50 0.30 0.50];
            rect_fa        = [0.00 0.25 0.30 0.25];
            rect_print     = [0.00 0.00 0.30 0.25];
            rect_pulselist = [0.30 0.00 0.70 1.00];
            self.flip_angle.add_uicontrol(container, rect_fa)
            self.button = uicontrol(container, ...
                'Style','pushbutton', ...
                'String','print', ...
                'Tooltip','print the pulse content AFTER parsing', ...
                'Units','normalized', ...
                'Position',rect_print, ...
                'Callback', @self.callback_button);
            self.pulse_list.add_uicontrol(container, rect_pulselist)
            self.file_list.add_uicontrol(container, rect_file)
        end % fcn

        function callback_button(self, ~, ~)
            display(self.pulse_data)
        end %fcn

        % pulses can be asymmetric : overload the method with a dedicated one
        function add_gz_rewinder(self, status)
            self.gz_rewinder.visible = "on";
            if nargin == 1, status = self.gz_rewinder.get(); end
            if ~status    , return                         , end

            [~,idx_max] = max(abs(self.B1));
            dur = self.time(end) - self.time(idx_max);

            n_new_points = round(self.n_points/2);
            self.time = [self.time linspace(self.time(end), self.time(end)+dur, n_new_points)];
            self.B1   = [self.B1   zeros(1,n_new_points)                                     ];
            self.GZ   = [self.GZ   -self.GZ(n_new_points+1:end)                              ];
        end % fcn

    end % meths

    methods (Access = protected)

        function list_pulse_name = load_file(self, filepath)
            [self.pulse_list_struct, self.file_info_struct] = mri_rf_pulse_sim.load_siemens_RFpulse(filepath);
            self.file_path = filepath;
            list_pulse_name = strcat({self.pulse_list_struct.family}, '/',  {self.pulse_list_struct.name})';
            if ~nargout
                self.pulse_list.items = string(list_pulse_name);
                self.pulse_list.value = list_pulse_name{1};
                self.pulse_name       = self.pulse_list.value;
                if ishandle(self.pulse_list.listbox)
                    self.pulse_list.listbox.String = self.pulse_list.items;
                    self.pulse_list.listbox.Value = 1;
                end
            end
        end % fcn

    end % meths

end % class
