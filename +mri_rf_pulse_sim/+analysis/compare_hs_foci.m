function varargout = compare_hs_foci()
% This function eveluate the slice profile of HS vs. FOCI at differnet maximum RF amplitude


%% Parameters

% generate FOCI pulse with default paramters
% since FOCI herits from HS, the FOCI object can call both generate_hs() and genertage_foci()
% using the exact same paramters.
pulse = mri_rf_pulse_sim.rf_pulse.foci();

% define spatial evaluation
dZ_mm = linspace(-pulse.slice_thickness.get(),+pulse.slice_thickness.get(),501); % millimeter
dZ    = dZ_mm * 1e-3;                                                            % meter

% define B0 field inhomogenity
dB0 = 0;   % in this exemple, assume no dB0

% static magnetic field
B0 = 2.89; % Tesla (value for Siemens 3T at 123MHz)

% Evaluate slice profile over these deferent max amplitude :
Amax_vect_ut = (3 : 3 : 18);        % micro tesla
Amax_vect    = Amax_vect_ut * 1e-6; % tesla


%% Computation (and plot)

solver = mri_rf_pulse_sim.bloch_solver(rf_pulse=pulse, B0=B0, SpatialPosition=dZ, DeltaB0=dB0);

% line 1 HS, line 2 is FOCI
final_Mz = zeros(2,length(Amax_vect));

fig = figure('Name',mfilename,'NumberTitle','off');
ax(1) = subplot(1,2,1);
ax(2) = subplot(1,2,2);
hold(ax, 'on');

colors = jet(length(Amax_vect));

for idx = 1 : length(Amax_vect)

    % update pulse (the solver has a reference to the pulse object)
    pulse.Amax.value = Amax_vect(idx);

    pulse.generate_hs();
    solver.solve();
    plot(ax(1), ...
        dZ_mm, ...
        solver.getSliceProfilePara(), ...
        'DisplayName', string(Amax_vect_ut(idx)) + " µT", ...
        'Color', colors(idx,:) ...
        )
    final_Mz(1,idx) = solver.getSliceMiddlePara();

    pulse.generate_foci();
    solver.solve();
    plot(ax(2), ...
        dZ_mm, ...
        solver.getSliceProfilePara(), ...
        'DisplayName', string(Amax_vect_ut(idx)) + " µT", ...
        'Color', colors(idx,:) ...
        )
    final_Mz(2,idx) = solver.getSliceMiddlePara();

end

legend()
xlabel('mm')
ylabel('Mz')


%%  Display inversion efficieny

efficiency = round(abs(final_Mz-1)/2 *100); % convert Mz from [-1 to +1] into [0% to 100%]

% and now print efficiency in a nice way
efficiency_table = array2table(efficiency);
efficiency_table.Properties.VariableNames = string(Amax_vect_ut) + " µT";
efficiency_table.Properties.RowNames = {'efficiency HS (%)', 'efficiency FOCI (%)'};
disp(efficiency_table)


%% Output ?

if nargout
    varargout{1} = efficiency_table;
    varargout{2} = fig;
end


end % fcn
