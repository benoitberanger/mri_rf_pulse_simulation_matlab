classdef slr < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % J. Pauly, P. Le Roux, D. Nishimura and A. Macovski, "Parameter
    % relations for the Shinnar-Le Roux selective excitation pulse design
    % algorithm (NMR imaging)," in IEEE Transactions on Medical Imaging,
    % vol. 10, no. 1, pp. 53-65, March 1991, doi: 10.1109/42.75611.
    %
    % dependency : https://github.com/LarsonLab/Spectral-Spatial-RF-Pulse-Design.git

    properties (GetAccess = public, SetAccess = public)
        d1          mri_rf_pulse_sim.ui_prop.scalar                        % [] ripple ratio on the rect top      (from 0 to 1)
        d2          mri_rf_pulse_sim.ui_prop.scalar                        % [] ripple ratio on the rect baseline (from 0 to 1)
        TBWP        mri_rf_pulse_sim.ui_prop.scalar                        % [] TimeBandWidthProduct -> needs to be an input parameter
        pulse_type  mri_rf_pulse_sim.ui_prop.list
        filter_type mri_rf_pulse_sim.ui_prop.list
        flip_angle  mri_rf_pulse_sim.ui_prop.scalar                        % [deg] flip angle
    end % props

    methods (Access = public)

        % constructor
        function self = slr()
            check_slr_dependency();
            self.n_points.value = 128;
            self.d1             = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='d1'         , value=  0.01, unit=' from 0 to 1');
            self.d2             = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='d2'         , value=  0.01, unit=' from 0 to 1');
            self.TBWP           = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='TBWP'       , value=  8                       );
            self.pulse_type     = mri_rf_pulse_sim.ui_prop.list  (parent=self, name=''           , value= 'ex' , items= {'st', 'ex', 'se', 'sat', 'inv'});
            self.filter_type    = mri_rf_pulse_sim.ui_prop.list  (parent=self, name=''           , value= 'min', items= {'ms', 'pm', 'ls', 'min', 'max'});
            self.flip_angle     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle' , value= 90   , unit='°'          );
            self.generate_slr();
            self.add_gz_rewinder();
        end % fcn

        function generate(self) % #abstract
            self.generate_slr();
            self.add_gz_rewinder();
        end % fcn

        function generate_slr(self)

            MAX_N = 512; % this value comes from the .c file, if the code is run with 512+ points MATLAB crashes
            assert(self.n_points.get() < MAX_N, 'n_points must be < %d', MAX_N)

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());
            self.GZ = ones(size(self.time)) * self.GZavg;

            % get waveform : https://github.com/LarsonLab/Spectral-Spatial-RF-Pulse-Design.git
            waveform = dzrf(self.n_points.get(), self.TBWP.get(), self.pulse_type.get(), self.filter_type.get(), self.d1.get(), self.d2.get());

            % scale waveform
            waveform = waveform / trapz(self.time, waveform); % normalize integral
            waveform = waveform * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.B1 = waveform;
        end % fcn

        function value = get_bandwidth(self) % #abstract
            value = self.get_slr_bandwidth();
        end % fcn

        function value = get_slr_bandwidth(self)
            value = self.TBWP / self.duration;
        end % fcn

        % SLR pulses can be asymmetric : overload the method with a dedicated one
        function add_gz_rewinder(self, status)
            self.gz_rewinder.visible = "on";
            if nargin == 1, status = self.gz_rewinder.get(); end
            if ~status    , return                         , end

            switch self.filter_type.get()
                case {'min','max'}
                    [~,idx_max] = max(abs(self.B1));
                    dur = self.time(end) - self.time(idx_max);
                otherwise
                    dur = self.duration/2;
            end

            n_new_points = round(self.n_points/2);
            self.time = [self.time linspace(self.time(end), self.time(end)+dur, n_new_points)];
            self.B1   = [self.B1   zeros(1,n_new_points)                                     ];
            self.GZ   = [self.GZ   -self.GZ(n_new_points+1:end)                              ];
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s]  d1=%g  d2=%g  TBWP=%g  ptype=%s  ftype=%s  FA=%g°',...
                mfilename, self.d1.get(), self.d2.get(), self.TBWP.get(), self.pulse_type.get(), self.filter_type.get(), self.flip_angle.get());
        end % fcn

        function init_specific_gui(self, container) % #abstract
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
