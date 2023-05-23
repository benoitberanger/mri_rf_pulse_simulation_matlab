function result = solve_bloch(Time, AmplitideModulation, FrequencyModulation, GradientModulation, SpatialPosition, DeltaB0, gamma)

% Define the time vector for simulation
dt = mean(diff(Time));

% Define the initial magnetization vector
M0 = [0; 0; 1];

% Preallocate variables for the magnetization vectors in ROTATING FRAME
result = zeros(3,length(Time),length(SpatialPosition),length(DeltaB0));

Sigma_x = [
    0 0 0;
    0 0 1;
    0 -1 0;
    ];

Sigma_y = [
    0 0 1;
    0 0 0;
    -1 0 0;
    ];

Sigma_z = [
    0 1 0;
    -1 0 0;
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

end % function
