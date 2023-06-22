function M = solve_bloch(Time, AmplitideModulation, FrequencyModulation, GradientModulation, SpatialPosition, DeltaB0, gamma)

% Define the time vector for simulation
dt = mean(diff(Time));

method = 'euler';

switch method

    case 'expm'

        % Define the initial magnetization vector
        M0 = [0; 0; 1];

        % Preallocate variables for the magnetization vectors in ROTATING FRAME
        result = zeros(3,length(Time),length(SpatialPosition),length(DeltaB0));

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
                M = zeros(3,length(Time));
                M(:,1) = M0;
                for t = 2:length(Time)

                    dM =...
                        Sigma_z * (dZ * GradientModulation(t-1) + dB0 ) * gamma + ...
                        gamma * AmplitideModulation(t-1) * (cos(2*pi*FrequencyModulation(t-1)*Time(t-1)) * Sigma_x + sin(2*pi*FrequencyModulation(t-1)*Time(t-1)) * Sigma_y) ;
                    M(:,t) = expm(dM*dt)*M(:,t-1);

                end % Time
                result(:,:,p,b) = M;

            end % SpatialPosition

        end % DeltaB0

        M = result;

    case 'euler'

        [Z , B] = meshgrid(SpatialPosition, DeltaB0);

        Z = Z(:);
        B = B(:);

        grid_size = length(Z);

        M = zeros(grid_size,3,length(Time));
        M(:,3,1) = 1;

        for t = 2:length(Time)

            Uz = (Z * GradientModulation(t-1) + B ) * gamma;
            Ux = gamma * AmplitideModulation(t-1) * cos(2*pi*FrequencyModulation(t-1)*Time(t-1));
            Uy = gamma * AmplitideModulation(t-1) * sin(2*pi*FrequencyModulation(t-1)*Time(t-1));

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

end

end % function
