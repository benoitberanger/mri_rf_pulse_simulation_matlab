classdef slr < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Shinnar - Le Roux

    properties (GetAccess = public, SetAccess = public)

        d1          mri_rf_pulse_sim.ui_prop.scalar                        % [] ripple ratio on the rect top      (from 0 to 1)
        d2          mri_rf_pulse_sim.ui_prop.scalar                        % [] ripple ratio on the rect baseline (from 0 to 1)
        TBWP        mri_rf_pulse_sim.ui_prop.scalar                        % [] TimeBandWidthProduct -> needs to be an input paramter
        pulse_type  mri_rf_pulse_sim.ui_prop.list
        filter_type mri_rf_pulse_sim.ui_prop.list
        flip_angle  mri_rf_pulse_sim.ui_prop.scalar                        % [deg] flip angle
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % Hz
    end % props

    methods % no attribute for dependent properies
        function value = get.bandwidth(self)
            value = self.TBWP / self.duration;
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = slr()
            check_slr_dependency();
            self.n_points.value = 64;
            self.d1             = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='d1'         , value=  0.01, unit='from 0 to 1');
            self.d2             = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='d2'         , value=  0.01, unit='from 0 to 1');
            self.TBWP           = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='TBWP'       , value=  8                       );
            self.pulse_type     = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='pulse_type' , value= 'ex' , items= {'st', 'ex', 'se', 'sat', 'inv'});
            self.filter_type    = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='filter_type', value= 'min', items= {'ms', 'pm', 'ls', 'min', 'max'});
            self.flip_angle     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle' , value= 90   , unit='°'          );
            self.generate_slr();
        end % fcn

        function generate(self)
            self.generate_slr();
        end % fcn

        % generate time, AM, FM, GM
        function generate_slr(self)

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());
            self.GZ = ones(size(self.time)) * self.GZavg;

            % get waveform : https://github.com/LarsonLab/Spectral-Spatial-RF-Pulse-Design.git
            waveform = dzrf(self.n_points.get(), self.TBWP.get(), self.pulse_type.get(), self.filter_type.get(), self.d1.get(), self.d2.get());

            % scale waveform
            waveform = waveform / trapz(self.time, waveform); % normalize integral
            waveform = waveform * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.B1 = waveform;

        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('slr : d1=%g  d2=%g  TBWP=%g  ptype=%s  ftype=%s  FA=%g°',...
                self.d1.get(), self.d2.get(), self.TBWP.get(), self.pulse_type.get(), self.filter_type.get(), self.flip_angle.get());
        end % fcn

        function init_specific_gui(self, container)
            rect_scalar = [0.0 0.0 0.6 1.0];
            rect_ptype  = [0.6 0.0 0.2 1.0];
            rect_ftype  = [0.8 0.0 0.2 1.0];
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.d1 self.d2 self.TBWP self.flip_angle],...
                rect_scalar...
                );
            self.pulse_type .add_uicontrol(container, rect_ptype);
            self.filter_type.add_uicontrol(container, rect_ftype);
        end % fcn

    end % meths

    methods (Access = private)
    end % meths

    methods(Static)

    end

end % class

function check_slr_dependency()

% the checks take non-neglectable time
persistent check_done
if check_done
    return
end

% check MATLAB toolbox dependency
tbx_list = {
    'DSP System Toolbox'
    'Signal Processing Toolbox'
    };
for idx = 1 : length(tbx_list)
    tbx = tbx_list{idx};
    assert(contains(struct2array(ver), tbx), 'MATLAB toolbox not present : %s', tbx)
end

% check if submodule is here
submodule_name = 'Spectral-Spatial-RF-Pulse-Design';
submodule_path = fullfile(mri_rf_pulse_sim.get_submodules_dir(), submodule_name);
assert(exist(submodule_path,'dir')>0 & exist(fullfile(submodule_path, 'rf_tools'),'dir')>0, ...
    'submodule (i.e. dependency) is required : %s. Update your git repo with `git submodule update', ...
    submodule_name)

% add in path
addpath(fullfile(submodule_path,'rf_tools'))
addpath(fullfile(submodule_path,'rf_tools','mex_files'))

check_done = true;
end
