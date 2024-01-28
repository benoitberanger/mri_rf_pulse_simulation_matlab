function varargout = evaluate_adiabaticity_hs()
% This function eveluate the slice profile of HyperbolicSecant (hs) pulse
% at differnet maximum RF amplitude


%% Parameters

% generate HS pulse with default paramters
pulse = mri_rf_pulse_sim.rf_pulse.hs();
fprintf('Analytical adiabaticity condition : Amax = %g µT \n', pulse.adiabatic_condition*1e6)

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(pulse);
n_dz = 301;
solver.setSpatialPosition(linspace(-pulse.slice_thickness.get(),+pulse.slice_thickness.get(),n_dz));
solver.setDeltaB0(0); % in this exemple, assume no dB0

% Evaluate slice profile over these deferent max amplitude :
vect = 2 : 2 : 20; % µT
Amax_range = mri_rf_pulse_sim.ui_prop.range(name='Amax', vect=vect*1e-6, unit='µT', scale=1e6);


%% Computation

% pre-allocation
all_slice_profile = zeros(solver.SpatialPosition.N,Amax_range.N);
mid_slice_profile = zeros(1                       ,Amax_range.N);

for idx = 1 : Amax_range.N
    % update pulse (the solver has a reference to the pulse object)
    pulse.Amax.value = Amax_range.vect(idx);
    pulse.generate();

    % solve and store
    solver.solve();
    all_slice_profile(:,idx) = solver.getSliceProfilePara();
    mid_slice_profile(idx)   = solver.getSliceMiddlePara();
end


%%  Display inversion efficieny

efficiency = round(abs(mid_slice_profile-1)/2 *100); % convert Mz from [-1 to +1] into [0% to 100%]

% and now print efficiency in a nice way
efficiency_table = array2table(efficiency);
efficiency_table.Properties.VariableNames = string(Amax_range.getScaled()) + " µT";
efficiency_table.Properties.RowNames = {'efficiency (%)'};
disp(efficiency_table)


%% Plot

fig = figure('Name',mfilename,'NumberTitle','off');

ax1 = subplot(4,1, 1:3);
colors = jet(Amax_range.N);
hold(ax1, 'on');
for idx = 1 : Amax_range.N
    plot(ax1, solver.SpatialPosition.getScaled, all_slice_profile(:,idx), ...
        'Color', colors(idx,:), ...
        'DisplayName', sprintf('%g %s', Amax_range.vect(idx)*Amax_range.scale, Amax_range.unit))
end
legend()
xlabel('mm')
ylabel('Mz')

ax2 = subplot(4,1, 4  );
plot(ax2, Amax_range.getScaled(), efficiency, 'Marker', 'x');
xlabel('µT')
ylabel(efficiency_table.Properties.RowNames)


%% Output ?

if nargout
    varargout{1} = efficiency_table;
    varargout{2} = fig;
end


end % fcn
