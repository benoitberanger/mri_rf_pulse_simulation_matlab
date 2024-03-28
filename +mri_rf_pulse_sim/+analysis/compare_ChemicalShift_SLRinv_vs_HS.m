function compare_ChemicalShift_SLRinv_vs_HS()
% This function will show a 2D plot SliceProfile x DeltaB0


%% Parameters

pulse1 = mri_rf_pulse_sim.rf_pulse.slr();
pulse1.pulse_type.value = 'inv';
pulse1.filter_type.value = 'ls';
pulse1.flip_angle.set(180);
pulse1.generate();

pulse2 = mri_rf_pulse_sim.rf_pulse.hs();

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz  = 301;
n_db0 = 301;
solver.setSpatialPosition(linspace(-pulse1.slice_thickness.get(),+pulse1.slice_thickness.get(),n_dz));
solver.DeltaB0.N = n_db0;


%% Computation

% slove and store

solver.setPulse(pulse1);
solver.solve();
DZxDB0_1 = solver.getSliceProfilePara(solver.DeltaB0.vect);
DZxDB0_1 = squeeze(DZxDB0_1);

solver.setPulse(pulse2);
solver.solve();
DZxDB0_2 = solver.getSliceProfilePara(solver.DeltaB0.vect);
DZxDB0_2 = squeeze(DZxDB0_2);


%% Plot

figure('Name',mfilename,'NumberTitle','off');

subplot(1,2,1)
[DZgrid, DB0grid] = meshgrid(solver.SpatialPosition.getScaled(),solver.DeltaB0.getScaled());
mysurf = surf(DZgrid, DB0grid, DZxDB0_1');
view(2)
xlabel('Slice position (mm)')
ylabel('Chemical shift (ppm)')
zlabel('M\perp')
mysurf.EdgeColor = 'none';
title('SLR inv')

subplot(1,2,2)
[DZgrid, DB0grid] = meshgrid(solver.SpatialPosition.getScaled(),solver.DeltaB0.getScaled());
mysurf = surf(DZgrid, DB0grid, DZxDB0_2');
view(2)
xlabel('Slice position (mm)')
ylabel('Chemical shift (ppm)')
zlabel('M\perp')
mysurf.EdgeColor = 'none';
title('HS')


end % fcn
