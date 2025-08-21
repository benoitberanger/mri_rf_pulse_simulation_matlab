function compare_hs_foci()
%% FOCI is derivezd from HS pulse. But is it better ?
% This function evaluate the slice profile of HS vs. FOCI at different maximum RF amplitude ($B1_{max}$).


%% Parameters

% generate FOCI pulse with default parameters
% since FOCI herits from HS, the FOCI object can call both generate_hs() and genertage_foci() using the exact same parameters.
pulse = mri_rf_pulse_sim.rf_pulse.foci();

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(pulse);
n_dz = 301;
solver.setSpatialPosition(linspace(-pulse.slice_thickness,+pulse.slice_thickness,n_dz));
solver.setDeltaB0(0); % in this example, assume no dB0

% Evaluate slice profile over these deferent max amplitude :
vect = 2 : 2 : 18; % µT
b1max_range = mri_rf_pulse_sim.ui_prop.range(name='b1max', vect=vect*1e-6, unit='µT', scale=1e6);

fig_size_px = [100 100 1600 800];


%% Plot HS and FOCI

fig1 = figure(Name=sprintf('[%s]: plot pulses', mfilename), NumberTitle='off', Units='pixels', Position=fig_size_px);
p1 = uipanel(Parent=fig1, Units="normalized",Position=[0.00 0.00 0.50 1.00], Title="HS");
p2 = uipanel(Parent=fig1, Units="normalized",Position=[0.50 0.00 0.50 1.00], Title="FOCI");

pulse.generate_hs();
pulse.plot(p1);
pulse.generate_foci();
pulse.plot(p2);


%% Computation

% pre-allocation
all_slice_profile = zeros(2,solver.SpatialPosition.N,b1max_range.N);
mid_slice_profile = zeros(2,1                       ,b1max_range.N);

for idx = 1 : b1max_range.N

    % update pulse (the solver has a reference to the pulse object)
    pulse.b1max.value = b1max_range.vect(idx);

    pulse.generate_hs();
    solver.solve();
    all_slice_profile(1,:,idx) = solver.getSliceProfilePara();
    mid_slice_profile(1,1,idx) = solver.getSliceMiddlePara();

    pulse.generate_foci();
    solver.solve();
    all_slice_profile(2,:,idx) = solver.getSliceProfilePara();
    mid_slice_profile(2,1,idx) = solver.getSliceMiddlePara();

end


%%  Display inversion efficiency

efficiency = round(abs(squeeze(mid_slice_profile)-1)/2 *100); % convert Mz from [+1 -> -1] into [0% -> 100%]

% and now print efficiency in a nice way
efficiency_table = array2table(efficiency);
efficiency_table.Properties.VariableNames = string(b1max_range.getScaled()) + " µT";
efficiency_table.Properties.RowNames = {'efficiency HS (%)', 'efficiency FOCI (%)'};
disp(efficiency_table)


%% Plot SliceProfile and Efficiency for both pulses

fig2 = figure(Name=sprintf('[%s]: plot slice profiles', mfilename), NumberTitle='off', Units='pixels', Position=fig_size_px);

ax1 = subplot('Position',[0.10 0.40 0.35 0.50], 'Parent',fig2);
ax2 = subplot('Position',[0.55 0.40 0.35 0.50], 'Parent',fig2);
hold([ax1 ax2], 'on');
colors = jet(b1max_range.N);
for idx = 1 : b1max_range.N
    plot(ax1, solver.SpatialPosition.getScaled, all_slice_profile(1,:,idx), ...
        'Color', colors(idx,:), ...
        'DisplayName', sprintf('%g %s', b1max_range.vect(idx)*b1max_range.scale, b1max_range.unit), ...
        'LineWidth',2)
    plot(ax2, solver.SpatialPosition.getScaled, all_slice_profile(2,:,idx), ...
        'Color', colors(idx,:), ...
        'DisplayName', sprintf('%g %s', b1max_range.vect(idx)*b1max_range.scale, b1max_range.unit), ...
        'LineWidth',2)
end
legend(ax1)
legend(ax2)
xlabel([ax1 ax2],'mm')
ylabel([ax1 ax2],'M\mid\mid')
title(ax1, 'HS')
title(ax2, 'FOCI')

ax3 = subplot('Position',[0.1 0.1 0.8 0.2], 'Parent',fig2);
plot(ax3, b1max_range.getScaled(), efficiency, 'Marker', 'x', 'LineWidth',2);
xlabel('µT')
ylabel('efficiency (%)')
legend({'HS', 'FOCI'})


end % fcn
