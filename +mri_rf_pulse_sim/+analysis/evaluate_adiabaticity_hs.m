function varargout = evaluate_adiabaticity_hs()
% This function evaluate the slice profile of HyperbolicSecant (hs) pulse
% at different maximum RF amplitude


%% Parameters

% generate HS pulse with default parameters
pulse = mri_rf_pulse_sim.rf_pulse.hs();
pulse.plot();

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(pulse);
n_dz = 301;
solver.setSpatialPosition(linspace(-pulse.slice_thickness.get(),+pulse.slice_thickness.get(),n_dz));
solver.setDeltaB0(0); % in this example, assume no dB0

% Evaluate slice profile over these deferent max amplitude :
vect = 2 : 2 : 26; % µT
b1max_range = mri_rf_pulse_sim.ui_prop.range(name='b1max', vect=vect*1e-6, unit='µT', scale=1e6);


%% Computation

% pre-allocation
all_slice_profile = zeros(solver.SpatialPosition.N,b1max_range.N);
mid_slice_profile = zeros(1                       ,b1max_range.N);

for idx = 1 : b1max_range.N
    % update pulse (the solver has a reference to the pulse object)
    pulse.b1max.value = b1max_range.vect(idx);
    pulse.generate();

    % solve and store
    solver.solve();
    all_slice_profile(:,idx) = solver.getSliceProfilePara();
    mid_slice_profile(idx)   = solver.getSliceMiddlePara();
end


%%  Display inversion efficiency

efficiency = round(abs(mid_slice_profile-1)/2 *100); % convert Mz from [-1 to +1] into [0% to 100%]

% and now print efficiency in a nice way
efficiency_table = array2table(efficiency);
efficiency_table.Properties.VariableNames = string(b1max_range.getScaled()) + " µT";
efficiency_table.Properties.RowNames = {'efficiency (%)'};
disp(efficiency_table)


%% Plot

fig = figure('Name',mfilename,'NumberTitle','off');

ax1 = subplot(4,1, 1:3);
colors = jet(b1max_range.N);
hold(ax1, 'on');
for idx = 1 : b1max_range.N
    plot(ax1, solver.SpatialPosition.getScaled, all_slice_profile(:,idx), ...
        'Color', colors(idx,:), ...
        'DisplayName', sprintf('%g %s', b1max_range.vect(idx)*b1max_range.scale, b1max_range.unit), ...
        'LineWidth',2)
end
legend()
xlabel('mm')
ylabel('Mz')

ax2 = subplot(4,1, 4  );
plot(ax2, b1max_range.getScaled(), efficiency, 'Marker', 'x', 'LineWidth',2);
xlabel('µT')
ylabel(efficiency_table.Properties.RowNames)


%% Output ?

if nargout
    varargout{1} = efficiency_table;
    varargout{2} = fig;
end


end % fcn
