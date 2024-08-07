function evaluate_adiabaticity_hs()
%% What does it mean *adiabatic* ?
% This function evaluate the slice profile of HyperbolicSecant (HS) pulse at different maximum RF amplitude ($B1_{max}$).


%% Parameters

% generate HS pulse with default parameters
pulse = mri_rf_pulse_sim.rf_pulse.hs();

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(pulse);
n_dz = 301;
solver.setSpatialPosition(linspace(-pulse.slice_thickness.get(),+pulse.slice_thickness.get(),n_dz));
solver.setDeltaB0(0); % in this example, assume no dB0

% Evaluate slice profile over these deferent max amplitude :
vect = 2 : 2 : 26; % µT
b1max_range = mri_rf_pulse_sim.ui_prop.range(name='b1max', vect=vect*1e-6, unit='µT', scale=1e6);


%% Plot pulse (default parameters)
% In this plot, the $B1_{max}$ is the default value.
% In the rest of the analysis, *only* the $B1_{max}$ will vary

fig1 = figure(Name=sprintf('[%s]: %s', mfilename, pulse.summary), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);
p1 = uipanel(Parent=fig1, Title=pulse.summary);
pulse.plot(p1);


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


%% Plot SliceProfile and Efficiency

fig2 = figure(Name=sprintf('[%s]: SliceProfile & Efficiency', mfilename), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);

ax(1) = subplot(4,1, 1:3, 'Parent',fig2);
ax(2) = subplot(4,1,   4, 'Parent',fig2);
hold(ax, 'all');
colors = jet(b1max_range.N);

% Slice profile
for idx = 1 : b1max_range.N
    plot(ax(1), solver.SpatialPosition.getScaled, all_slice_profile(:,idx), ...
        'Color', colors(idx,:), ...
        'DisplayName', sprintf('%g %s', b1max_range.vect(idx)*b1max_range.scale, b1max_range.unit), ...
        'LineWidth',2)
end
legend(ax(1))
xlabel(ax(1),'mm')
ylabel(ax(1),'M\mid\mid')

% Efficiency
plot(ax(2), b1max_range.getScaled(), efficiency, 'Marker', 'x', 'LineWidth',2);
xlabel(ax(2),'µT')
ylabel(ax(2),efficiency_table.Properties.RowNames)
xlim(ax(2),[min(b1max_range.getScaled()) max(b1max_range.getScaled())])
xticks(ax(2),b1max_range.getScaled())
grid(ax(2),'minor')


end % fcn
