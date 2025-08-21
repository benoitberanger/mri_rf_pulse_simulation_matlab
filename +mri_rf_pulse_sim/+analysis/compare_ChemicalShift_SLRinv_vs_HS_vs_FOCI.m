function compare_ChemicalShift_SLRinv_vs_HS_vs_FOCI()
%% Why adiabatic pulses are interesting in case of DeltaB0 ?
% This function will compare the spatial displacement due to chemical shift between different pulses
%
% REMINDER
%
% CSDE is Chemichal Shift Displacement Error
% dW = dB0 is chemical shift
%
% CSDE = (dW * B0) / BW


%% Parameters

pulse1 = mri_rf_pulse_sim.rf_pulse.slr();
pulse1.pulse_type.value = 'inv';
pulse1.filter_type.value = 'ls';
pulse1.flip_angle.set(180);
pulse1.generate();

pulse2 = mri_rf_pulse_sim.rf_pulse.hs();

pulse3 = mri_rf_pulse_sim.rf_pulse.foci();

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz  = 301;
n_db0 = 301;
solver.setSpatialPosition(linspace(-pulse1.slice_thickness*2,+pulse1.slice_thickness*2,n_dz));
solver.DeltaB0.N = n_db0;


%% Computation
% solve and store

solver.setPulse(pulse1);
solver.solve();
DZxDB0_1 = solver.getSliceProfilePara(solver.DeltaB0.vect);
DZxDB0_1 = squeeze(DZxDB0_1);

solver.setPulse(pulse2);
solver.solve();
DZxDB0_2 = solver.getSliceProfilePara(solver.DeltaB0.vect);
DZxDB0_2 = squeeze(DZxDB0_2);

solver.setPulse(pulse3);
solver.solve();
DZxDB0_3 = solver.getSliceProfilePara(solver.DeltaB0.vect);
DZxDB0_3 = squeeze(DZxDB0_3);


%% fetch chemical shift displacement

Z_middle_1 = zeros(1,solver.DeltaB0.N);
Z_middle_2 = zeros(1,solver.DeltaB0.N);
Z_middle_3 = zeros(1,solver.DeltaB0.N);
for idx_cs = 1 : solver.DeltaB0.N

    cs = DZxDB0_1(:,idx_cs);
    [val_min_Mperp_1,idx_min_Mperp_1] = min(cs);
    halfval_min_Mperp_1 = val_min_Mperp_1/2;
    [val_L_halfval_min_Mperp_1,idx_L_halfval_min_Mperp_1] = min(abs(cs(              1:idx_min_Mperp_1) - halfval_min_Mperp_1));
    [val_R_halfval_min_Mperp_1,idx_R_halfval_min_Mperp_1] = min(abs(cs(idx_min_Mperp_1:end            ) - halfval_min_Mperp_1));
    idx_middle_1 = round((idx_R_halfval_min_Mperp_1+idx_L_halfval_min_Mperp_1)/2);
    Z_middle_1(idx_cs) = solver.SpatialPosition.vect(idx_L_halfval_min_Mperp_1)*solver.SpatialPosition.scale;

    cs = DZxDB0_2(:,idx_cs);
    [val_min_Mperp_2,idx_min_Mperp_2] = min(cs);
    halfval_min_Mperp_2 = val_min_Mperp_2/2;
    [val_L_halfval_min_Mperp_2,idx_L_halfval_min_Mperp_2] = min(abs(cs(              1:idx_min_Mperp_2) - halfval_min_Mperp_2));
    [val_R_halfval_min_Mperp_2,idx_R_halfval_min_Mperp_2] = min(abs(cs(idx_min_Mperp_2:end            ) - halfval_min_Mperp_2));
    idx_middle_2 = round((idx_R_halfval_min_Mperp_2+idx_L_halfval_min_Mperp_2)/2);
    Z_middle_2(idx_cs) = solver.SpatialPosition.vect(idx_L_halfval_min_Mperp_2)*solver.SpatialPosition.scale;

    cs = DZxDB0_3(:,idx_cs);
    [val_min_Mperp_3,idx_min_Mperp_3] = min(cs);
    halfval_min_Mperp_3 = val_min_Mperp_3/2;
    [val_L_halfval_min_Mperp_3,idx_L_halfval_min_Mperp_3] = min(abs(cs(              1:idx_min_Mperp_3) - halfval_min_Mperp_3));
    [val_R_halfval_min_Mperp_3,idx_R_halfval_min_Mperp_3] = min(abs(cs(idx_min_Mperp_3:end            ) - halfval_min_Mperp_3));
    idx_middle_3 = round((idx_R_halfval_min_Mperp_3+idx_L_halfval_min_Mperp_3)/2);
    Z_middle_3(idx_cs) = solver.SpatialPosition.vect(idx_L_halfval_min_Mperp_3)*solver.SpatialPosition.scale;

end


%% fit chemical shift displacement

p1 = polyfit(solver.DeltaB0.getScaled,Z_middle_1, 1);
p2 = polyfit(solver.DeltaB0.getScaled,Z_middle_2, 1);
p3 = polyfit(solver.DeltaB0.getScaled,Z_middle_3, 1);

fprintf('SLR inv : CS displacement = %f mm/ppm \n', abs(p1(1)))
fprintf('HS      : CS displacement = %f mm/ppm \n', abs(p2(1)))
fprintf('FOCI    : CS displacement = %f mm/ppm \n', abs(p3(1)))


%% Plot
%
% * on the top, 2D plots SlicePosition x ChemicalShoft
% * on the bottom, the ChemicalShift Displacement Error

[DZgrid, DB0grid] = meshgrid(solver.SpatialPosition.getScaled(),solver.DeltaB0.getScaled());

figure(Name=sprintf('[%s]', mfilename), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);

subplot(2,3,1)
title('SLR inv')
mysurf = surf(DZgrid, DB0grid, DZxDB0_1');
view(2)
xlabel('Slice position (mm)')
ylabel('Chemical shift (ppm)')
zlabel('M\perp')
mysurf.EdgeColor = 'none';

subplot(2,3,2)
mysurf = surf(DZgrid, DB0grid, DZxDB0_2');
title('HS')
view(2)
xlabel('Slice position (mm)')
ylabel('Chemical shift (ppm)')
zlabel('M\perp')
mysurf.EdgeColor = 'none';

subplot(2,3,3)
title('FOCI')
mysurf = surf(DZgrid, DB0grid, DZxDB0_3');
view(2)
xlabel('Slice position (mm)')
ylabel('Chemical shift (ppm)')
zlabel('M\perp')
mysurf.EdgeColor = 'none';

subplot(2,3,[4 5 6])
title('SlicePisiton = function(ChemicalShift)')
hold on
plot(solver.DeltaB0.getScaled,Z_middle_1)
plot(solver.DeltaB0.getScaled,Z_middle_2)
plot(solver.DeltaB0.getScaled,Z_middle_3)
xlabel('Chemical shift (ppm)')
ylabel('Slice position (mm)')
legend({'SLR inv', 'HS', 'FOCI'})


end % fcn
