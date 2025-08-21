classdef bloch_solver < handle & matlab.mixin.CustomCompactDisplayProvider

    properties (GetAccess = public, SetAccess = public)
        rf_pulse                                                           % pointer to rf pulse object
        B0                    mri_rf_pulse_sim.ui_prop.scalar              % [T] static magnetic field strength
        SpatialPosition       mri_rf_pulse_sim.ui_prop.range               % [m] spatial Z offcet to evaluate magnetization -> this evaluates the slice profile
        DeltaB0               mri_rf_pulse_sim.ui_prop.range               % [T] B0 offcet, expressed in ppm
        M0                    mri_rf_pulse_sim.ui_prop.vec3                % [] initial magnetization vector
        T1                    mri_rf_pulse_sim.ui_prop.scalar              % [s] T1 relaxtion coefficient : set to +Inf by default
        T2                    mri_rf_pulse_sim.ui_prop.scalar              % [s] T2 relaxtion coefficient : set to +Inf by default
        % gamma -> from rf_pulse
        % time  -> from rf_pulse
    end % pros

    properties (GetAccess = public, SetAccess = protected)
        M                     double                                       % result of the simulation
        dim             (1,1) struct                                       % labels for M dimensions
    end % props

    methods (Access = public)

        %------------------------------------------------------------------
        % constructor
        %------------------------------------------------------------------
        function self = bloch_solver(args)
            arguments
                args.rf_pulse
                args.B0
                args.SpatialPosition
                args.DeltaB0
                args.M0
                args.T1
                args.T2
            end

            % do not define .rf_pulse -> let the user do it
            self.B0              = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='B0'             , value=3.00                               , unit='T'  );
            self.SpatialPosition = mri_rf_pulse_sim.ui_prop.range (parent=self, name='SpatialPosition', vect=linspace(-10,+10,11)*1e-3, scale=1e3, unit='mm' );
            self.DeltaB0         = mri_rf_pulse_sim.ui_prop.range (parent=self, name='DelatB0'        , vect=linspace(-10,+10, 3)*1e-6, scale=1e6, unit='ppm');
            self.M0              = mri_rf_pulse_sim.ui_prop.vec3  (parent=self, name='M0'             , xyz=[0 0 1]'                                         );
            self.T1              = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='T1'             , value=+Inf                    , scale=1e3, unit='ms' );
            self.T2              = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='T2'             , value=+Inf                    , scale=1e3, unit='ms' );

            if isfield(args, 'rf_pulse'       ), self.setPulse          (args.rf_pulse       ); end
            if isfield(args, 'B0'             ), self.setB0             (args.B0             ); end
            if isfield(args, 'SpatialPosition'), self.setSpatialPosition(args.SpatialPosition); end
            if isfield(args, 'DeltaB0'        ), self.setDeltaB0        (args.DeltaB0        ); end
            if isfield(args, 'M0'             ), self.setM0             (args.M0             ); end
            if isfield(args, 'T1'             ), self.setT1             (args.T1             ); end
            if isfield(args, 'T2'             ), self.setT2             (args.T1             ); end

        end % fcn

        %------------------------------------------------------------------
        % get/set methods
        %------------------------------------------------------------------

        function setPulse(self, value)
            if isa(value, 'mri_rf_pulse_sim.backend.rf_pulse.abstract')
                self.rf_pulse = value;
            else
                error('bad input type')
            end
        end % fcn

        function setB0(self, value)
            switch class(value)
                case 'mri_rf_pulse_sim.ui_prop.scalar', self.B0       = value;
                case 'double'                         , self.B0.value = value;
                otherwise, error('bad input type')
            end
        end % fcn

        function setSpatialPosition(self, value)
            switch class(value)
                case 'mri_rf_pulse_sim.ui_prop.range', self.SpatialPosition      = value;
                case 'double'                        , self.SpatialPosition.vect = value;
                otherwise, error('bad input type')
            end
        end % fcn

        function setDeltaB0(self, value)
            switch class(value)
                case 'mri_rf_pulse_sim.ui_prop.range', self.DeltaB0      = value;
                case 'double'                        , self.DeltaB0.vect = value;
                otherwise, error('bad input type')
            end
        end % fcn

        function setM0(self, value)
            switch class(value)
                case 'mri_rf_pulse_sim.ui_prop.vec3', self.M0     = value;
                case 'double'                       , self.M0.xyz = value;
                otherwise, error('bad input type')
            end
        end % fcn

        function setT1(self, value)
            switch class(value)
                case 'mri_rf_pulse_sim.ui_prop.scalar', self.T1       = value;
                case 'double'                         , self.T1.value = value;
                otherwise, error('bad input type')
            end
        end % fcn

        function setT2(self, value)
            switch class(value)
                case 'mri_rf_pulse_sim.ui_prop.scalar', self.T2       = value;
                case 'double'                         , self.T2.value = value;
                otherwise, error('bad input type')
            end
        end % fcn

        %------------------------------------------------------------------
        % other methods
        %------------------------------------------------------------------

        % getTimeseries
        function value = getTimeseriesX   (self, varargin), value = self.getTimeseries("x"   ,varargin{:}); end
        function value = getTimeseriesY   (self, varargin), value = self.getTimeseries("y"   ,varargin{:}); end
        function value = getTimeseriesZ   (self, varargin), value = self.getTimeseries("z"   ,varargin{:}); end
        function value = getTimeseriesXYZ (self, varargin), value = self.getTimeseries("xyz" ,varargin{:}); end
        function value = getTimeseriesPara(self, varargin), value = self.getTimeseries("para",varargin{:}); end
        function value = getTimeseriesPerp(self, varargin), value = self.getTimeseries("perp",varargin{:}); end
        function value = getTimeseries    (self, axis, dZ, dB0)
            arguments
                self
                axis string {mustBeMember(axis,["x","y","z","xyz","para","perp"])}
                dZ   = []
                dB0  = []
            end
            [sel, comb] = axis2selcomb(axis);
            if isempty(dZ)
                idx_dZ = self.SpatialPosition.middle_idx;
            else
                idx_dZ = find(self.SpatialPosition.vect == dZ);
            end
            if isempty(dB0)
                idx_dB0 = self.DeltaB0.middle_idx;
            else
                idx_dB0 = find(self.DeltaB0.vect == dB0);
            end
            selection = cell(length(fieldnames(self.dim)), 1);
            selection{self.dim.time} = ':';
            selection{self.dim.XYZ } = sel;
            selection{self.dim.dZ  } = idx_dZ;
            selection{self.dim.dB0 } = idx_dB0;
            value = squeeze(self.M(selection{:}));
            if comb
                value = sqrt(sum(value.^2,2));
            end
        end

        % getSliceProfile
        function value = getSliceProfileX   (self, varargin), value = self.getSliceProfile("x"   ,varargin{:}); end
        function value = getSliceProfileY   (self, varargin), value = self.getSliceProfile("y"   ,varargin{:}); end
        function value = getSliceProfileZ   (self, varargin), value = self.getSliceProfile("z"   ,varargin{:}); end
        function value = getSliceProfileXYZ (self, varargin), value = self.getSliceProfile("xyz" ,varargin{:}); end
        function value = getSliceProfilePara(self, varargin), value = self.getSliceProfile("para",varargin{:}); end
        function value = getSliceProfilePerp(self, varargin), value = self.getSliceProfile("perp",varargin{:}); end
        function value = getSliceProfile    (self, axis, dB0)
            arguments
                self
                axis string {mustBeMember(axis,["x","y","z","xyz","para","perp"])}
                dB0  = []
            end
            [sel, comb] = axis2selcomb(axis);
            if isempty(dB0)
                idx_dB0 = self.DeltaB0.middle_idx;
            else
                idx_dB0 = find(self.DeltaB0.vect == dB0);
            end
            selection = cell(length(fieldnames(self.dim)), 1);
            selection{self.dim.time} = length(self.rf_pulse.time); % last timepoint
            selection{self.dim.XYZ } = sel;
            selection{self.dim.dZ  } = ':';
            selection{self.dim.dB0 } = idx_dB0;
            value = squeeze(self.M(selection{:}));
            if comb
                value = sqrt(sum(value.^2,1));
            end
        end

        % getSliceMiddle
        function value = getSliceMiddleX   (self, varargin), value = self.getSliceMiddle("x"   ,varargin{:}); end
        function value = getSliceMiddleY   (self, varargin), value = self.getSliceMiddle("y"   ,varargin{:}); end
        function value = getSliceMiddleZ   (self, varargin), value = self.getSliceMiddle("z"   ,varargin{:}); end
        function value = getSliceMiddleXYZ (self, varargin), value = self.getSliceMiddle("xyz" ,varargin{:}); end
        function value = getSliceMiddlePara(self, varargin), value = self.getSliceMiddle("para",varargin{:}); end
        function value = getSliceMiddlePerp(self, varargin), value = self.getSliceMiddle("perp",varargin{:}); end
        function value = getSliceMiddle    (self, axis, dB0)
            arguments
                self
                axis string {mustBeMember(axis,["x","y","z","xyz","para","perp"])}
                dB0  = []
            end
            [sel, comb] = axis2selcomb(axis);
            if isempty(dB0)
                idx_B0 = self.DeltaB0.middle_idx;
            else
                idx_B0 = find(self.DeltaB0.vect == dB0);
            end
            selection = cell(length(fieldnames(self.dim)), 1);
            selection{self.dim.time} = length(self.rf_pulse.time); % last timepoint
            selection{self.dim.XYZ } = sel;
            selection{self.dim.dZ  } = self.SpatialPosition.middle_idx;
            selection{self.dim.dB0 } = idx_B0;
            value = squeeze(self.M(selection{:}));
            if comb
                value = sqrt(sum(value.^2));
            end
        end

        % getChemicalShift
        function value = getChemicalShiftX   (self, varargin), value = self.getChemicalShift("x"   ,varargin{:}); end
        function value = getChemicalShiftY   (self, varargin), value = self.getChemicalShift("y"   ,varargin{:}); end
        function value = getChemicalShiftZ   (self, varargin), value = self.getChemicalShift("z"   ,varargin{:}); end
        function value = getChemicalShiftXYZ (self, varargin), value = self.getChemicalShift("xyz" ,varargin{:}); end
        function value = getChemicalShiftPara(self, varargin), value = self.getChemicalShift("para",varargin{:}); end
        function value = getChemicalShiftPerp(self, varargin), value = self.getChemicalShift("perp",varargin{:}); end
        function value = getChemicalShift    (self, axis, dZ)
            arguments
                self
                axis string {mustBeMember(axis,["x","y","z","xyz","para","perp"])}
                dZ  = []
            end
            [sel, comb] = axis2selcomb(axis);
            if isempty(dZ)
                idx_dZ = self.SpatialPosition.middle_idx;
            else
                idx_dZ = find(self.SpatialPosition.vect == dZ);
            end
            selection = cell(length(fieldnames(self.dim)), 1);
            selection{self.dim.time} = length(self.rf_pulse.time); % last timepoint
            selection{self.dim.XYZ } = sel;
            selection{self.dim.dZ  } = idx_dZ;
            selection{self.dim.dB0 } = ':';
            value = squeeze(self.M(selection{:}));
            if comb
                value = sqrt(sum(value.^2));
            end
        end

        % solve bloch equations equation : RF field, GZ gradient, T1 & T2 relaxation, but no diffusion
        function solve(self)
            assert(~isempty(self.rf_pulse), '[%s]: missing rf_pulse', mfilename)

            [Zgrid , Bgrid] = meshgrid(self.SpatialPosition.get(), self.DeltaB0.get());

            Zgrid = Zgrid(:);
            Bgrid = Bgrid(:);

            grid_size = length(Zgrid);

            m = zeros(grid_size,3,length(self.rf_pulse.time));
            m(:,1,1) = self.M0.x;
            m(:,2,1) = self.M0.y;
            m(:,3,1) = self.M0.z;

            B1real = self.rf_pulse.real();
            B1imag = self.rf_pulse.imag();

            use_T1_relaxiation = false;
            use_T2_relaxiation = false;
            if isfinite(self.T1.value)
                use_T1_relaxiation = true;
            end
            if isfinite(self.T2.value)
                use_T2_relaxiation = true;
            end

            for t = 2:length(self.rf_pulse.time)

                dt = self.rf_pulse.time(t) - self.rf_pulse.time(t-1);

                Uz = (Zgrid * self.rf_pulse.GZ(t-1) + Bgrid*self.B0) * self.rf_pulse.gamma;
                Ux = self.rf_pulse.gamma * B1real(t-1);
                Uy = self.rf_pulse.gamma * B1imag(t-1);

                phy = atan2(               Uy , Ux);
                the = atan2(sqrt(Ux.^2+Uy.^2) , Uz);
                chi = sqrt(Ux.^2+Uy.^2+Uz.^2) * dt;

                cos_phy = cos(phy);
                sin_phy = sin(phy);
                cos_the = cos(the);
                sin_the = sin(the);
                cos_chi = cos(chi);
                sin_chi = sin(chi);

                % Rz + phy
                m(:,1,t) =  cos_phy .* m(:,1,t-1) + sin_phy .* m(:,2,t-1);
                m(:,2,t) = -sin_phy .* m(:,1,t-1) + cos_phy .* m(:,2,t-1);
                m(:,3,t) = m(:,3,t-1);

                % Ry + the
                Mprev = m(:,:,t);
                m(:,1,t) =  cos_the .* Mprev(:,1) - sin_the .* Mprev(:,3);
                m(:,3,t) =  sin_the .* Mprev(:,1) + cos_the .* Mprev(:,3);

                % Rz - chi
                Mprev = m(:,:,t);
                m(:,1,t) =  cos_chi .* Mprev(:,1) - sin_chi .* Mprev(:,2);
                m(:,2,t) =  sin_chi .* Mprev(:,1) + cos_chi .* Mprev(:,2);

                % Ry - the
                Mprev = m(:,:,t);
                m(:,1,t) =  cos_the .* Mprev(:,1) + sin_the .* Mprev(:,3);
                m(:,3,t) = -sin_the .* Mprev(:,1) + cos_the .* Mprev(:,3);

                % Rz - phy
                Mprev = m(:,:,t);
                m(:,1,t) =  cos_phy .* Mprev(:,1) - sin_phy .* Mprev(:,2);
                m(:,2,t) =  sin_phy .* Mprev(:,1) + cos_phy .* Mprev(:,2);

                % Relaxation
                % !!! Separation of Rotation THEN Relaxation induce an error linear with 'dt' !!!
                if use_T2_relaxiation
                    m(:,1,t) = m(:,1,t)              .* exp( -dt / self.T2 );
                    m(:,2,t) = m(:,2,t)              .* exp( -dt / self.T2 );
                end
                if use_T1_relaxiation
                    m(:,3,t) =(m(:,3,t) - self.M0.z) .* exp( -dt / self.T1 ) + self.M0.z;
                end

            end % time

            m = reshape(m, [self.DeltaB0.N self.SpatialPosition.N 3 length(self.rf_pulse.time)]);
            m = permute(m, [4 3 2 1]);
            self.M = m;

            self.dim.time = 1;
            self.dim.XYZ  = 2;
            self.dim.dZ   = 3;
            self.dim.dB0  = 4;

        end % fcn

        function [F, Y_scaled] = getFFTApproxPerp(self)
            [F, Y] = getFFTApprox(self);
            Y = Y / Y(round(end/2));
            y = self.getChemicalShiftPerp();
            Y_scaled = Y * y(round(end/2));
        end % fcn
        function [F, Y_scaled] = getFFTApproxPara(self)
            [F, Y] = getFFTApprox(self);
            Y_scaled = (Y/Y(round(end/2))*2-1);
            y = self.getChemicalShiftPara();
            Y_scaled = Y_scaled * y(round(end/2));
        end % fcn

        function plotFFTApproxPerp(self)
            [F, Y] = getFFTApproxPerp(self);
            self.plotFFTApprox(F, Y, self.getChemicalShiftPerp());
        end % fcn
        function plotFFTApproxPara(self)
            [F, Y] = getFFTApproxPara(self);
            self.plotFFTApprox(F, Y, self.getChemicalShiftPara());
        end % fcn

    end % meths

    methods (Access = protected)

        function [F, Y] = getFFTApprox(self)
            assert(~isempty(self.rf_pulse), '[%s]: missing rf_pulse', mfilename)
            L = self.rf_pulse.n_points.get();
            N = L*100;
            Y = fftshift(fft(self.rf_pulse.B1,N));
            dt = mean(diff(self.rf_pulse.time));
            F = 1/dt * (-N/2 : (N/2-1)) / N;
            Y = abs(Y);
        end % fcn

        function plotFFTApprox(self, freq, y_fft, y_block)
            figure('NumberTitle','off', 'Name',sprintf('FFT apprixmation : %s', class(self.rf_pulse)))
            hold on
            plot(freq, y_fft, 'DisplayName', 'FFT')
            plot(self.B0.get()*self.DeltaB0.getScaled()*self.rf_pulse.gamma*1e-6/(2*pi), y_block, 'DisplayName', 'Bloch')
            legend
            xlim([-self.rf_pulse.bandwidth +self.rf_pulse.bandwidth]*2)
        end % fcn

    end

end % class

function [sel, comb] = axis2selcomb(axis)
switch axis
    case "x"   , sel = 1;   comb = 0;
    case "y"   , sel = 2;   comb = 0;
    case "z"   , sel = 3;   comb = 0;
    case "xyz" , sel = 1:3; comb = 0;
    case "para", sel = 3;   comb = 0;
    case "perp", sel = 1:2; comb = 1;
end
end % fcn
