function evaluate_adiabaticity_hs()
%% What does it mean *adiabatic* ?
% This function evaluate the slice profile of HyperbolicSecant (HS) pulse at different maximum RF amplitude ($B1_{max}$).

% evaluate pulse chemical shift profile in this ppm range
target_range_db0 = 5; % ppm

% Evaluate slice profile over these deferent max amplitude :
vect = 1 : 1 : 30; % µT
b1max_range = mri_rf_pulse_sim.ui_prop.range(name='b1max', vect=vect*1e-6, unit='µT', scale=1e6);


%% Parameters

% generate HS pulse with default parameters
pulse = mri_rf_pulse_sim.rf_pulse.hs();
pulse.bw.set(3000); % Hz
pulse.slice_thickness.set(Inf); % set non-selective pulse

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(pulse);
solver.setSpatialPosition(0); % non-selective pulse, don't look at off-center effects
solver.setDeltaB0(0); % in this example, assume no dB0
n_db0 = 301;
solver.setDeltaB0(linspace(-target_range_db0*4,+target_range_db0*4,n_db0)*1e-6);


%% Plot pulse (default parameters)
% In this plot, the $B1_{max}$ is the default value.
% In the rest of the analysis, *only* the $B1_{max}$ will vary

fig1 = figure(Name=sprintf('[%s]: %s', mfilename, pulse.summary), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);
p1 = uipanel(Parent=fig1, Title=pulse.summary);
pulse.plot(p1);


%% Computation

% pre-allocation
all_chemical_profile = zeros(solver.DeltaB0.N,b1max_range.N);

for idx = 1 : b1max_range.N
    % update pulse (the solver has a reference to the pulse object)
    pulse.b1max.value = b1max_range.vect(idx);
    pulse.generate();

    % solve and store
    solver.solve();
    all_chemical_profile(:,idx) = solver.getChemicalShiftPara();
end


%%  Display inversion efficiency

lower_bound = solver.DeltaB0.getScaled() >= -target_range_db0/2;
upper_bound = solver.DeltaB0.getScaled() <= +target_range_db0/2;
idx_bound = lower_bound & upper_bound;
good_range = all_chemical_profile(idx_bound,:);

efficiency = round(abs(mean(good_range,1)-1)/2 *100); % convert Mz from [-1 to +1] into [0% to 100%]

% and now print efficiency in a nice way
efficiency_table = array2table(efficiency);
efficiency_table.Properties.VariableNames = string(b1max_range.getScaled()) + " µT";
efficiency_table.Properties.RowNames = {'efficiency (%)'};
disp(efficiency_table)


%% Plot ChemicalProfile and Efficiency

fig2 = figure(Name=sprintf('[%s]: ChemicalProfile & Efficiency', mfilename), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);

ax(1) = subplot(4,1, 1:3, 'Parent',fig2);
ax(2) = subplot(4,1,   4, 'Parent',fig2);
hold(ax, 'all');
colors = jet(b1max_range.N);

% Chemical profile
for idx = 1 : b1max_range.N
    plot(ax(1), solver.DeltaB0.getScaled(), all_chemical_profile(:,idx), ...
        'Color', colors(idx,:), ...
        'DisplayName', sprintf('%g %s', b1max_range.vect(idx)*b1max_range.scale, b1max_range.unit), ...
        'LineWidth',2)
end
legend(ax(1))
xlabel(ax(1),'ppm')
ylabel(ax(1),'M\mid\mid')

% Efficiency
plot(ax(2), b1max_range.getScaled(), efficiency, 'Marker', 'x', 'LineWidth',2);
xlabel(ax(2),'µT')
ylabel(ax(2),efficiency_table.Properties.RowNames)
xlim(ax(2),[min(b1max_range.getScaled()) max(b1max_range.getScaled())])
xticks(ax(2),b1max_range.getScaled())
grid(ax(2),'minor')


end % fcn
