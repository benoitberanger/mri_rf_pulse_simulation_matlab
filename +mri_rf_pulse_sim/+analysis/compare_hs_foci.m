function varargout = compare_hs_foci()
% This function eveluate the slice profile of HS vs. FOCI at differnet maximum RF amplitude


%% Parameters

% generate FOCI pulse with default paramters
% since FOCI herits from HS, the FOCI object can call both generate_hs() and genertage_foci()
% using the exact same paramters.
pulse = mri_rf_pulse_sim.rf_pulse.foci();

pulse.generate_foci();
pulse.plot();
pulse.generate_hs();
pulse.plot();

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(pulse);
n_dz = 301;
solver.setSpatialPosition(linspace(-pulse.slice_thickness.get(),+pulse.slice_thickness.get(),n_dz));
solver.setDeltaB0(0); % in this exemple, assume no dB0

% Evaluate slice profile over these deferent max amplitude :
vect = 2 : 2 : 18; % µT
Amax_range = mri_rf_pulse_sim.ui_prop.range(name='Amax', vect=vect*1e-6, unit='µT', scale=1e6);


%% Computation (and plot)

% pre-allocation
all_slice_profile = zeros(2,solver.SpatialPosition.N,Amax_range.N);
mid_slice_profile = zeros(2,1                       ,Amax_range.N);

for idx = 1 : Amax_range.N

    % update pulse (the solver has a reference to the pulse object)
    pulse.Amax.value = Amax_range.vect(idx);

    pulse.generate_hs();
    solver.solve();
    all_slice_profile(1,:,idx) = solver.getSliceProfilePara();
    mid_slice_profile(1,1,idx) = solver.getSliceMiddlePara();

    pulse.generate_foci();
    solver.solve();
    all_slice_profile(2,:,idx) = solver.getSliceProfilePara();
    mid_slice_profile(2,1,idx) = solver.getSliceMiddlePara();

end


%%  Display inversion efficieny

efficiency = round(abs(squeeze(mid_slice_profile)-1)/2 *100); % convert Mz from [-1 to +1] into [0% to 100%]

% and now print efficiency in a nice way
efficiency_table = array2table(efficiency);
efficiency_table.Properties.VariableNames = string(Amax_range.getScaled()) + " µT";
efficiency_table.Properties.RowNames = {'efficiency HS (%)', 'efficiency FOCI (%)'};
disp(efficiency_table)


%% Plot

fig = figure('Name',mfilename,'NumberTitle','off');

ax1 = subplot('Position', [0.10 0.40 0.35 0.50]);
ax2 = subplot('Position', [0.55 0.40 0.35 0.50]);
hold([ax1 ax2], 'on');
colors = jet(Amax_range.N);
for idx = 1 : Amax_range.N
    plot(ax1, solver.SpatialPosition.getScaled, all_slice_profile(1,:,idx), ...
        'Color', colors(idx,:), ...
        'DisplayName', sprintf('%g %s', Amax_range.vect(idx)*Amax_range.scale, Amax_range.unit), ...
        'LineWidth',2)
    plot(ax2, solver.SpatialPosition.getScaled, all_slice_profile(2,:,idx), ...
        'Color', colors(idx,:), ...
        'DisplayName', sprintf('%g %s', Amax_range.vect(idx)*Amax_range.scale, Amax_range.unit), ...
        'LineWidth',2)
end
legend(ax1)
legend(ax2)
xlabel([ax1 ax2],'mm')
ylabel([ax1 ax2],'Mz')
title(ax1, 'HS')
title(ax2, 'FOCI')

ax3 = subplot('Position', [0.1 0.1 0.8 0.2]);
plot(ax3, Amax_range.getScaled(), efficiency, 'Marker', 'x', 'LineWidth',2);
xlabel('µT')
ylabel('efficiency (%)')
legend({'HS', 'FOCI'})


%% Output ?

if nargout
    varargout{1} = efficiency_table;
    varargout{2} = fig;
end


end % fcn
