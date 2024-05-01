classdef sinc_self_refocusing < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Pauly J, Nishimura D, Macovski A. A k-space analysis of small-tip-angle
    % excitation. 1989. J Magn Reson. 2011 Dec;213(2):544-57. doi:
    % 10.1016/j.jmr.2011.09.023. PMID: 22152370.

    properties (GetAccess = public, SetAccess = public)
        n_side_lobs mri_rf_pulse_sim.ui_prop.scalar                        % [] number of side lobs, from 1 to +Inf
        flip_angle  mri_rf_pulse_sim.ui_prop.scalar                        % [deg] flip angle
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % [Hz]  #abstract
    end % props

    methods % no attribute for dependent properties
        function value = get.bandwidth(self)
            value = (2*self.n_side_lobs) / self.duration;
        end % fcn
    end % meths

    methods (Access = public)

        % constructor
        function self = sinc_self_refocusing()
            self.n_side_lobs = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='n_side_lobs',  value=7          );
            self.flip_angle  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle' , value=90, unit='°');
            self.generate();
        end % fcn

        function generate(self) % #abstract
            self.generate_sinc_self_refocusing();
        end % fcn

        function generate_sinc_self_refocusing(self)
            self.assert_nonempty_prop({'n_points', 'duration', 'n_side_lobs', 'flip_angle'})
            assert(mod(self.n_points.get(),4)==0, 'n_points must be a multiple of 4')

            self.time   = linspace(-self.duration/2, +self.duration/2, self.n_points.get());

            % generate standard SINC pulse for the middle part
            time_middle = linspace(-self.duration/4, +self.duration/4, self.n_points/2    );
            lob_size_middle = 1/self.bandwidth/2;
            b1_middle = sinc(time_middle/lob_size_middle); % base shape
            gz_middle = ones(size(time_middle)) * self.GZavg;

            % then replicate the half of the middle on each side, with L/R swap
            b1_left   =  b1_middle(1:self.n_points/4);
            b1_right  =  b1_middle(self.n_points/4+1:end);
            gz_left   = -gz_middle(1:self.n_points/4);
            gz_right  = -gz_middle(self.n_points/4+1:end);
            b1        = [b1_right b1_middle b1_left];
            gz        = [gz_right gz_middle gz_left];

            % adjust amplitudes
            b1 = b1 / trapz(self.time, b1); % normalize integral
            b1 = b1 * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.B1  = b1;
            self.GZ  = gz*2;
        end % fcn

        function txt = summary(self) % #abstract
            txt = sprintf('[%s] : n_side_lobs=%s  flip_angle=%s',...
                mfilename, self.n_side_lobs.repr, self.flip_angle.repr);
        end % fcn

        function init_specific_gui(self, container) % #abstract
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.n_side_lobs, self.flip_angle]...
                );
        end % fcn

    end % meths

end % class
