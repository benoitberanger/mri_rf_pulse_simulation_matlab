classdef sinc < mri_rf_pulse_sim.backend.rf_pulse.duration_based

    properties (GetAccess = public, SetAccess = public)
        n_lobs     mri_rf_pulse_sim.ui_prop.scalar                         % [] number of lobs, from 1 to +Inf
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle
        gz         mri_rf_pulse_sim.ui_prop.scalar                         % [T/m] slice/slab selection gradient

        window                                                             % window object
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth       (1,1) double                                       % Hz
        slice_thickness (1,1) double                                       % [m]
    end % props

    methods % no attribute for dependent properies
        function value = get.bandwidth(self)
            value = (2*self.n_lobs) / self.duration;
        end% % fcn
        function value = get.slice_thickness(self)
            value = 2*pi * self.bandwidth / (self.gamma * self.Gz__max);
        end % fcn
        function set.window(self,value)
            assert(isa(value,'mri_rf_pulse_sim.backend.window.abstract'))
            self.window = value;
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = sinc()
            self.n_lobs     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_lobs'    ,  value=7                               );
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=90       , unit='°'              );
            self.gz         = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='gz'        , value=10 * 1e-3, unit='mT/m', scale=1e3);
            self.generate_sinc();
        end % fcn

        function generate(self)
            self.generate_sinc();
        end % fcn

        % generate time, AM, FM, GM
        function generate_sinc(self)
            self.assert_nonempty_prop({'n_points', 'duration', 'n_lobs'})

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());

            lob_size = 1/self.bandwidth;

            self.amplitude_modulation = sinc(self.time/lob_size); % base shape
            if ~isempty(self.window) && isvalid(self.window)
                self.amplitude_modulation = self.amplitude_modulation .* self.window.shape; % windowing
            end
            self.amplitude_modulation = self.amplitude_modulation / trapz(self.time, self.amplitude_modulation); % normalize integral
            self.amplitude_modulation = self.amplitude_modulation * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.frequency_modulation = zeros(size(self.time));
            self.gradient_modulation  = ones(size(self.time)) * self.gz;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('sinc : n_lobs=%d  flip_angle=%d°  gz=%gmT/m',...
                self.n_lobs.get(), self.flip_angle.get(), self.gz.get());
        end % fcn

        function set_window(self, name)
            if nargin < 2
                name = '';
            end

            switch name
                case {'','none','NONE'}
                    self.window = mri_rf_pulse_sim.window.base.empty;
                otherwise
                    list = mri_rf_pulse_sim.window.get_list();
                    assert(any(strcmp(list,name)), 'incorrect window name')
                    fullname = sprintf('mri_rf_pulse_sim.window.%s', name);
                    self.window = feval(fullname, rf_pulse=self);
            end
            self.generate();
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n_lobs, self.flip_angle, self.gz],...
                [0 0.2 1 0.8]...
                );

            handles = guidata(container);
            uicontrol(container,...
                'Style'          ,'pushbutton'                  ,...
                'String'         ,'Windowing'                   ,...
                'Units'          ,'normalized'                  ,...
                'Position'       ,[0 0 1 0.2]                   ,...
                'BackgroundColor',handles.buttonBGcolor         ,...
                'Callback'       ,@self.callback_open_window_gui)
        end % fcn

    end % meths

    methods(Access = protected)
        function callback_open_window_gui(self,varargin)
            self.app.open_window_gui();
        end % fcn

    end % meths

end % class
