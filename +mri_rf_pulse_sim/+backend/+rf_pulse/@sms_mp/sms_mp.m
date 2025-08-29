classdef (Abstract) sms_mp < handle
    % Han V, Liu C. Multiphoton magnetic resonance in imaging: A classical
    % description and implementation. Magn Reson Med. 2020; 84: 1184–1197.
    % https://doi.org/10.1002/mrm.28186
    %
    % Han V, Chi J, Ipek TD, Chen J, Liu C. Pulsed selective excitation
    % theory and design in multiphoton MRI. J Magn Reson. 2023;348:107376.
    % doi:10.1016/j.jmr.2023.107376

    properties (GetAccess = public, SetAccess = public)
        slice_distance mri_rf_pulse_sim.ui_prop.scalar                     % [m] distance between each slice
        gz_modulation  mri_rf_pulse_sim.ui_prop.bool                       % []
        shift          mri_rf_pulse_sim.ui_prop.list                       % []
        ac_factor      mri_rf_pulse_sim.ui_prop.scalar                     % []
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        band_seperation (1,1) double                                       % [Hz]
    end % props
    properties (GetAccess = protected, SetAccess = protected, Dependent)
        j1              (1,1) double
    end % props

    methods % no attribute for dependent properties
        function value = get.band_seperation(self), value = self.bandwidth * self.slice_distance/self.slice_thickness; end
        function value = get.j1             (self), value = besselj(1,self.ac_factor.get())                          ; end
    end % meths

    methods(Access = public)

        % constructor
        function self = sms_mp()
            self.slice_distance = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='slice_distance', value=6* 1e-3, unit='mm', scale=1e3);
            self.gz_modulation  = mri_rf_pulse_sim.ui_prop.bool  (parent=self, name='gz_modulation' , value=true, text='gz_modulation');
            self.shift          = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='n_photon'      , value="Center+Left+Right", items=["Center" "Left" "Right" "Center+Left+Right"]);
            self.ac_factor      = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='ac_factor'     , value=1.5);
        end

        function make_multiphoton(self)
            if self.gz_modulation
                self.GZ = self.GZ + sin(2*pi*self.band_seperation * self.time) * self.GZavg * self.ac_factor;
            end

            switch self.shift.get()
                case "None"
                case "Left"
                    self.B1 = self.get_shift("Left");
                case "Right"
                    self.B1 = self.get_shift("Right");
                case "Center+Left+Right"
                    center_pulse_scale = (besselj(0,0) + besselj(2,2*self.ac_factor) - 2*self.j1 ) / (1-self.j1);
                    normalization_factor = center_pulse_scale + 2*self.j1;
                    self.B1 = ...
                        self.B1 * center_pulse_scale  +  ...
                        self.get_shift("Left" ) * self.j1 + ...
                        self.get_shift("Right") * self.j1 ;
                    self.B1 = self.B1 / normalization_factor;
            end

        end % fcn

        function add_gz_rewinder_mp(self)
            self.gz_rewinder.visible = "on";
            if nargin == 1, status = self.gz_rewinder.get(); end
            if ~status    , return                         , end

            rewinder_ampl = self.GZavg;

            n_new_points = round(self.n_points/2);
            self.time = [self.time linspace(self.time(end), self.time(end)+self.duration/2, n_new_points)];
            self.B1   = [self.B1   zeros(1,n_new_points)                                                 ];
            self.GZ   = [self.GZ   -ones(1,n_new_points)*rewinder_ampl                                   ];
        end % fcn

        function init_mp_gui(self, container)
            self.slice_distance.add_uicontrol(container, [0.00 0.75 1.00 0.25])
            self.gz_modulation .add_uicontrol(container, [0.00 0.25 0.50 0.50])
            self.shift         .add_uicontrol(container, [0.50 0.25 0.50 0.50])
            self.ac_factor     .add_uicontrol(container, [0.00 0.00 1.00 0.25])
        end % fcn

    end % meths

    methods(Access = private)

        function new_B1 = get_shift(self, type)
            new_B1 = self.B1;
            switch type
                case "Left"
                    SIGN = -1;
                case "Right"
                    SIGN = +1;
            end
            new_B1 = new_B1 .* exp(SIGN * 1j * 2*pi*self.band_seperation * self.time);
            new_B1 = new_B1 .* exp(SIGN * 1j * (self.ac_factor*(1 - cos(2*pi*self.band_seperation * self.time))));
            new_B1 = new_B1 / self.j1;
        end % fcn

    end

end % class
