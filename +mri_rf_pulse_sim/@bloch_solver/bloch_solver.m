classdef bloch_solver < handle & matlab.mixin.CustomCompactDisplayProvider

    properties (GetAccess = public, SetAccess = public)
        rf_pulse                                                           % pointer to rf pulse object
        B0                    mri_rf_pulse_sim.ui_prop.scalar              % [T] static magnetic field strength
        SpatialPosition       mri_rf_pulse_sim.ui_prop.range               % [m] spatial Z offcet to evaluate magnetization -> this evaluates the slice profile
        DeltaB0               mri_rf_pulse_sim.ui_prop.range               % [T] B0 offcet, expressed in ppm
        Mxyz0           (3,1) double                                       % [] initial magnetization vector
        % gamma -> from rf_pulse
        % time -> from rf_pulse
    end % pros

    properties (GetAccess = public, SetAccess = protected)
        M                     double                                       % result of the simulation
        dim             (1,1) struct                                       % labels for M dimentions
    end % props

    methods (Access = public)

        % contructor
        function self = bloch_solver(args)
            arguments
                args.B0
                args.SpatialPosition
                args.DeltaB0
                args.Mxyz0
            end

            if isfield(args, 'B0')
                self.setB0(args.B0);
            else
                self.B0 = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='B0', value=2.89, unit='T');
            end

            if isfield(args, 'SpatialPosition')
                self.setSpatialPosition(args.SpatialPosition);
            else
                self.SpatialPosition = mri_rf_pulse_sim.ui_prop.range (parent=self, name='SpatialPosition', vect=linspace(-10,+10,11)*1e-3, scale=1e3, unit='mm' );
            end

            if isfield(args, 'DeltaB0')
                self.setDeltaB0(args.DeltaB0)
            else
                self.DeltaB0 = mri_rf_pulse_sim.ui_prop.range (parent=self, name='DelatB0', vect=linspace(-10,+10, 3)*1e-6, scale=1e6, unit='ppm');
            end

            if isfield(args, 'Mxyz0')
                self.Mxyz0 = args.Mxyz0;
            else
                self.Mxyz0 = [0; 0; 1];
            end

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

        function setMxyz0(self, value)
            switch class(value)
                case 'double', self.Mxyz0 = value;
                otherwise, error('bad input type')
            end
        end % fcn

        %------------------------------------------------------------------
        % other methods
        %------------------------------------------------------------------

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

            switch axis
                case "x"   , sel = 1;   combine = 0;
                case "y"   , sel = 2;   combine = 0;
                case "z"   , sel = 3;   combine = 0;
                case "xyz" , sel = 1:3; combine = 0;
                case "para", sel = 1:2; combine = 1;
                case "perp", sel = 3;   combine = 0;
            end

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
            if combine
                value = sum(value.^2,2);
            end
        end

        function value = getSliceProfileX   (self, varargin), value = self.getSliceProfile("x"   ,varargin{:}); end
        function value = getSliceProfileY   (self, varargin), value = self.getSliceProfile("y"   ,varargin{:}); end
        function value = getSliceProfileZ   (self, varargin), value = self.getSliceProfile("z"   ,varargin{:}); end
        function value = getSliceProfileXYZ (self, varargin), value = self.getSliceProfile("xyz" ,varargin{:}); end
        function value = getSliceProfilePara(self, varargin), value = self.getSliceProfile("para",varargin{:}); end
        function value = getSliceProfilePerp(self, varargin), value = self.getSliceProfile("perp",varargin{:}); end
        function value = getSliceProfile    (self, axis, dZ)
            arguments
                self
                axis string {mustBeMember(axis,["x","y","z","xyz","para","perp"])}
                dZ  = []
            end

            switch axis
                case "x"   , sel = 1;   combine = 0;
                case "y"   , sel = 2;   combine = 0;
                case "z"   , sel = 3;   combine = 0;
                case "xyz" , sel = 1:3; combine = 0;
                case "para", sel = 1:2; combine = 1;
                case "perp", sel = 3;   combine = 0;
            end
            if nargin < 2
                idx_dZ = self.DeltaB0.middle_idx;
            else
                idx_dZ = find(self.DeltaB0.vect == dZ);
            end
            selection = cell(length(fieldnames(self.dim)), 1);
            selection{self.dim.time} = self.rf_pulse.n_points.get(); % last timepoint
            selection{self.dim.XYZ } = sel;
            selection{self.dim.dZ  } = idx_dZ;
            selection{self.dim.dB0 } = ':';
            value = squeeze(self.M(selection{:}));
            if combine
                value = sum(value.^2,1);
            end
        end

        %         function value = getSliceMiddle(self, dB0)
        %             if nargin < 2
        %                 idx_dB0 = self.DeltaB0.middle_idx;
        %             else
        %                 idx_dB0 = find(self.DeltaB0.vect == dB0);
        %             end
        %             selection = cell(length(fieldnames(self.dim)), 1);
        %             selection{self.dim.time} = self.rf_pulse.n_points.get();
        %             selection{self.dim.XYZ } = 3;
        %             selection{self.dim.dZ  } = self.SpatialPosition.middle_idx;
        %             selection{self.dim.dB0 } = idx_dB0;
        %             value = self.M(selection{:});
        %         end


        function value = getChemicalShiftX   (self, varargin), value = self.getChemicalShift("x"   ,varargin{:}); end
        function value = getChemicalShiftY   (self, varargin), value = self.getChemicalShift("y"   ,varargin{:}); end
        function value = getChemicalShiftZ   (self, varargin), value = self.getChemicalShift("z"   ,varargin{:}); end
        function value = getChemicalShiftXYZ (self, varargin), value = self.getChemicalShift("xyz" ,varargin{:}); end
        function value = getChemicalShiftPara(self, varargin), value = self.getChemicalShift("para",varargin{:}); end
        function value = getChemicalShiftPerp(self, varargin), value = self.getChemicalShift("perp",varargin{:}); end
        function value = getChemicalShift    (self, axis, dB0)
            arguments
                self
                axis string {mustBeMember(axis,["x","y","z","xyz","para","perp"])}
                dB0  = []
            end

            switch axis
                case "x"   , sel = 1;   combine = 0;
                case "y"   , sel = 2;   combine = 0;
                case "z"   , sel = 3;   combine = 0;
                case "xyz" , sel = 1:3; combine = 0;
                case "para", sel = 1:2; combine = 1;
                case "perp", sel = 3;   combine = 0;
            end
            if nargin < 2
                idx_dB0 = self.SpatialPosition.middle_idx;
            else
                idx_dB0 = find(self.SpatialPosition.vect == dB0);
            end
            selection = cell(length(fieldnames(self.dim)), 1);
            selection{self.dim.time} = self.rf_pulse.n_points.get(); % last timepoint
            selection{self.dim.XYZ } = sel;
            selection{self.dim.dZ  } = ':';
            selection{self.dim.dB0 } = idx_dB0;
            value = squeeze(self.M(selection{:}));
            if combine
                value = sum(value.^2,1);
            end
        end

        function solve(self)
            assert(~isempty(self.rf_pulse), '[%s]: missing rf_pulse', mfilename)

            [Zgrid , Bgrid] = meshgrid(self.SpatialPosition.get(), self.DeltaB0.get());

            Zgrid = Zgrid(:);
            Bgrid = Bgrid(:);

            grid_size = length(Zgrid);

            m = zeros(grid_size,3,length(self.rf_pulse.time));
            m(:,1,1) = self.Mxyz0(1);
            m(:,2,1) = self.Mxyz0(2);
            m(:,3,1) = self.Mxyz0(3);

            B1mag = self.rf_pulse.mag();
            B1pha = self.rf_pulse.pha();

            for t = 2:length(self.rf_pulse.time)

                dt = self.rf_pulse.time(t) - self.rf_pulse.time(t-1);

                Uz = (Zgrid * self.rf_pulse.GZ(t-1) + Bgrid*self.B0 ) * self.rf_pulse.gamma;
                Ux = self.rf_pulse.gamma * B1mag(t-1) * cos(B1pha(t-1));
                Uy = self.rf_pulse.gamma * B1mag(t-1) * sin(B1pha(t-1));

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

            end % time

            m = reshape(m, [self.DeltaB0.N self.SpatialPosition.N 3 length(self.rf_pulse.time)]);
            m = permute(m, [4 3 2 1]);
            self.M = m;

            self.dim.time = 1;
            self.dim.XYZ  = 2;
            self.dim.dZ   = 3;
            self.dim.dB0  = 4;

        end % fcn

    end % meths

end % class
