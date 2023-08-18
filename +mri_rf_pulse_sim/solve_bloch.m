function M = solve_bloch(Time, B1, GZ, SpatialPosition, DeltaB0, gamma, B0)

method = 'euler';

switch method

    case 'expm'

        % Define the initial magnetization vector
        M0 = [0; 0; 1];

        % Preallocate variables for the magnetization vectors in ROTATING FRAME
        M = zeros(3,length(Time),length(SpatialPosition),length(DeltaB0));

        Sigma_x = [
            0 0 0;
            0 0 -1;
            0 1 0;
            ];

        Sigma_y = [
            0 0 1;
            0 0 0;
            -1 0 0;
            ];

        Sigma_z = [
            0 -1 0;
            1 0 0;
            0 0 0;
            ];

        for b = 1 : length(DeltaB0)
            dB0 = DeltaB0(b);

            for p = 1 : length(SpatialPosition)
                dZ = SpatialPosition(p);

                % Loop through time and solve the Bloch equations numerically
                m = zeros(3,length(Time));
                m(:,1) = M0;
                for t = 2:length(Time)
                    
                    dt = Time(t) - Time(t-1);
                    dm =...
                        Sigma_z * (dZ * GradientModulation(t-1) + dB0*B0 ) * gamma + ...
                        gamma * AmplitideModulation(t-1) * (cos(2*pi*FrequencyModulation(t-1)*Time(t-1)) * Sigma_x + sin(2*pi*FrequencyModulation(t-1)*Time(t-1)) * Sigma_y) ;
                    m(:,t) = expm(dm*dt)*m(:,t-1);

                end % Time
                M(:,:,p,b) = m;

            end % SpatialPosition

        end % DeltaB0

    case 'euler'

        [Zgrid , Bgrid] = meshgrid(SpatialPosition, DeltaB0);

        Zgrid = Zgrid(:);
        Bgrid = Bgrid(:);

        grid_size = length(Zgrid);

        M = zeros(grid_size,3,length(Time));
        M(:,3,1) = 1;

        B1mag = abs  (B1);
        B1pha = angle(B1);

        for t = 2:length(Time)

            dt = Time(t) - Time(t-1);
            
            Uz = (Zgrid * GZ(t-1) + Bgrid*B0 ) * gamma;
            Ux = gamma * B1mag(t-1) * cos(B1pha(t-1));
            Uy = gamma * B1mag(t-1) * sin(B1pha(t-1));

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
            M(:,1,t) =  cos_phy .* M(:,1,t-1) + sin_phy .* M(:,2,t-1);
            M(:,2,t) = -sin_phy .* M(:,1,t-1) + cos_phy .* M(:,2,t-1);
            M(:,3,t) = M(:,3,t-1);

            % Ry + the
            Mprev = M(:,:,t);
            M(:,1,t) =  cos_the .* Mprev(:,1) - sin_the .* Mprev(:,3);
            M(:,3,t) =  sin_the .* Mprev(:,1) + cos_the .* Mprev(:,3);

            % Rz - chi
            Mprev = M(:,:,t);
            M(:,1,t) =  cos_chi .* Mprev(:,1) - sin_chi .* Mprev(:,2);
            M(:,2,t) =  sin_chi .* Mprev(:,1) + cos_chi .* Mprev(:,2);

            % Ry - the
            Mprev = M(:,:,t);
            M(:,1,t) =  cos_the .* Mprev(:,1) + sin_the .* Mprev(:,3);
            M(:,3,t) = -sin_the .* Mprev(:,1) + cos_the .* Mprev(:,3);

            % Rz - phy
            Mprev = M(:,:,t);
            M(:,1,t) =  cos_phy .* Mprev(:,1) - sin_phy .* Mprev(:,2);
            M(:,2,t) =  sin_phy .* Mprev(:,1) + cos_phy .* Mprev(:,2);

        end % Time

        M = reshape(M, [length(DeltaB0) length(SpatialPosition) 3 length(Time)]);
        M = permute(M, [3 4 2 1]);

end % switch::method

end % function
