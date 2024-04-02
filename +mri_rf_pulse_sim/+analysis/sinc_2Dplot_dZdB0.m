function sinc_2Dplot_dZdB0()
% This function will show a 2D plot SliceProfile x DeltaB0


%% Parameters

pulse = mri_rf_pulse_sim.rf_pulse.sinc();

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz  = 301;
n_db0 = 301;
solver.setPulse(pulse);
solver.setSpatialPosition(linspace(-pulse.slice_thickness.get(),+pulse.slice_thickness.get(),n_dz));
solver.DeltaB0.N = n_db0;


%% Computation

% solve and store
solver.solve();
DZxDB0 = solver.getSliceProfilePerp(solver.DeltaB0.vect);
DZxDB0 = squeeze(DZxDB0); % ?? why there is an empty dimension


%% Plot

figure('Name',mfilename,'NumberTitle','off');
[DZgrid, DB0grid] = meshgrid(solver.SpatialPosition.getScaled(),solver.DeltaB0.getScaled());
mysurf = surf(DZgrid, DB0grid, DZxDB0');
xlabel('Slice position (mm)')
ylabel('Chemical shift (ppm)')
zlabel('M\perp')
mysurf.EdgeColor = 'none';


end % fcn
