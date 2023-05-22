classdef sinc < mri_rf_pulse_sim.rf_pulse.base

    properties (GetAccess = public, SetAccess = public, SetObservable)

        n_lobs     (1,1) double {mustBePositive, mustBeInteger}            =  7         % [] number of lobs, from 1 to +Inf
        flip_angle (1,1) double {mustBePositive}                           = 90         % [deg] flip angle
        gz         (1,1) double                                            = 10 * 1e-3  % [T/m] slice/slab selection gradient

    end % props

    properties (GetAccess = public, SetAccess = {?mri_rf_pulse_sim.rf_pulse.base}, Hidden)
        ui__n_lobs     matlab.ui.control.UIControl                           % pointer to the GUI object
        ui__flip_angle matlab.ui.control.UIControl                           % pointer to the GUI object
        ui__gz         matlab.ui.control.UIControl                           % pointer to the GUI object
    end % props

    methods (Access = public)

        % constructor
        function self = sinc()
            self.generate();
        end % fcn

        % generate time, AM, FM, GM
        function generate(self)
            self.assert_nonempty_prop({'n_points', 'duration', 'n_lobs'})

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points);

            lob_size = self.duration / (2*self.n_lobs);

            self.amplitude_modulation = sinc(self.time/lob_size); % base shape
            self.amplitude_modulation = self.amplitude_modulation / trapz(self.time, self.amplitude_modulation); % normalize integral
            self.amplitude_modulation = self.amplitude_modulation * deg2rad(self.flip_angle) / self.gamma; % scale integrale with flip angle
            self.frequency_modulation = zeros(size(self.time));
            self.gradient_modulation  = ones(size(self.time)) * self.gz;

            self.B1__max = max(self.amplitude_modulation);
            self.gz__max = self.gz;
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('sinc : n_lobs=%d  flip_angle=%d°  gz=%gmT/m',...
                self.n_lobs, self.flip_angle, self.gz*1e3);
        end % fcn

    end % meths

    methods (Access = {?mri_rf_pulse_sim.pulse_definition})

        function init_specific_gui(self, container)
            handles = guidata(container);

            handles = self.add_synced_props(container, handles, ...
                {
                % prop                   text      scale
                'n_lobs'              'n_lobs = '  1
                'flip_angle'  'flip angle (°) = '  1
                'gz'               'gz (mT/m) = '  1e-3
                });

            guidata(handles.fig, handles);
        end % fcn

    end % meths

end % class
