classdef sinc < mri_rf_pulse_sim.backend.rf_pulse.abstract

    properties (GetAccess = public, SetAccess = public)
        n_side_lobs mri_rf_pulse_sim.ui_prop.scalar                        % [] number of side lobs, from 1 to +Inf
        flip_angle  mri_rf_pulse_sim.ui_prop.scalar                        % [deg] flip angle
        rf_phase       mri_rf_pulse_sim.ui_prop.scalar                     % [deg] phase of the pulse (typically used for spoiling)

        window                                                             % window object
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
    end % props

    methods % no attribute for dependent properties
        function value = get.bandwidth(self)
            value = (2*self.n_side_lobs) / self.duration;
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
            self.n_side_lobs    = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_side_lobs', value= 2          );
            self.flip_angle     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle' , value=90, unit='°');
            self.rf_phase       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='rf_phase'   , value= 0, unit='°');
            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_sinc();
            self.add_gz_rewinder();
        end % fcn

        function generate_sinc(self)
            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());

            lob_size = 1/self.bandwidth;

            waveform = sinc(self.time/lob_size); % base shape
            if ~isempty(self.window) && isvalid(self.window)
                waveform = waveform .* self.window.shape; % windowing
            end
            waveform = waveform / trapz(self.time, waveform); % normalize integral
            waveform = waveform * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.B1  = waveform * exp(1j * deg2rad(self.rf_phase.get()));
            self.GZ  = ones(size(self.time)) * self.GZavg;
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s] : n_side_lobs=%s  flip_angle=%s  rf_phase=%s',...
                mfilename, self.n_side_lobs.repr, self.flip_angle.repr, self.rf_phase.repr);
            if ~isempty(self.window) && isvalid(self.window)
                txt = sprintf('%s  window=%s', txt, self.window.name);
            end
        end % fcn

        function set_window(self, name)
            if nargin < 2
                name = '';
            end

            switch name
                case {'','none','NONE'}
                    self.window = mri_rf_pulse_sim.window.base.empty;
                otherwise
                    fullname = sprintf('mri_rf_pulse_sim.window.%s', name);
                    self.window = feval(fullname, rf_pulse=self);
            end
            self.generate();
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n_side_lobs, self.flip_angle self.rf_phase],...
                [0 0.2 1 0.8]...
                );

            fig_col = mri_rf_pulse_sim.backend.gui.get_fig_colors();
            uicontrol(container,...
                'Style'          ,'pushbutton'                  ,...
                'String'         ,'Windowing'                   ,...
                'Units'          ,'normalized'                  ,...
                'Position'       ,[0 0 1 0.2]                   ,...
                'BackgroundColor',fig_col.buttonBG              ,...
                'Callback'       ,@self.callback_open_window_gui)
        end % fcn

    end % meths

    methods(Access = protected)
        function callback_open_window_gui(self,varargin)
            self.app.open_window_gui();
        end % fcn

    end % meths

end % class
