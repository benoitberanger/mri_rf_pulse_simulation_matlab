classdef sinc < mri_rf_pulse_sim.backend.rf_pulse.abstract

    properties (GetAccess = public, SetAccess = public)
        n_lobs     mri_rf_pulse_sim.ui_prop.scalar                         % [] number of lobs, from 1 to +Inf
        flip_angle mri_rf_pulse_sim.ui_prop.scalar                         % [deg] flip angle

        window                                                             % window object
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % Hz
    end % props

    methods % no attribute for dependent properies
        function value = get.bandwidth(self)
            value = (2*self.n_lobs) / self.duration;
        end% % fcn
        function set.window(self,value)
            assert(isa(value,'mri_rf_pulse_sim.backend.window.abstract'))
            self.window = value;
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = sinc()
            self.n_points.value = 128;
            self.n_lobs         = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_lobs'    ,  value=7          );
            self.flip_angle     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=90, unit='°');
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

            waveform = sinc(self.time/lob_size); % base shape
            if ~isempty(self.window) && isvalid(self.window)
                waveform = waveform .* self.window.shape; % windowing
            end
            waveform = waveform / trapz(self.time, waveform); % normalize integral
            waveform = waveform * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.B1  = waveform;
            self.GZ  = ones(size(self.time)) * self.GZavg;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('sinc : n_lobs=%d  flip_angle=%d°',...
                self.n_lobs.get(), self.flip_angle.get());
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
                [self.n_lobs, self.flip_angle],...
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
