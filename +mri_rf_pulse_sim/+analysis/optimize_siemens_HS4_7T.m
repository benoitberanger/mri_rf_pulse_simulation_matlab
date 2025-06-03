% function optimize_siemens_hs4()
clear
clc

% set base paramters of the pulse
pulse = mri_rf_pulse_sim.rf_pulse.SIEMENS();
pulse.pulse_list.value = "IR12800H180/IR180_HS4";
pulse.slice_thickness.set(Inf); % set non-selective pulse

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(pulse);
solver.setSpatialPosition(0);
solver.setB0(7);
solver.T1.setScaled(1450);
solver.T2.setScaled(50);
n_db0 = 301;
target_range_db0 = 5; % ppm
solver.setDeltaB0(linspace(-target_range_db0,+target_range_db0,n_db0)*1e-6);

% range of evaluated values
eval_dur = [3 5 7 10 12]; % ms
eval_fa  = 150 : 50 : 500; % fa

[grid_dur, grid_fa] = ndgrid(eval_dur, eval_fa);
nr = numel(grid_dur);

chemical_profile = zeros(solver.DeltaB0.N,nr);
for i = 1 : nr
    pulse.duration.set(grid_dur(i)*1e-3)
    pulse.flip_angle.set(grid_fa(i))
    pulse.generate()
    solver.solve()
    chemical_profile(:, i) = solver.getChemicalShiftPara();
end

%%

clc

lower_bound = solver.DeltaB0.getScaled() >= -target_range_db0/2;
upper_bound = solver.DeltaB0.getScaled() <= +target_range_db0/2;
idx_bound = lower_bound & upper_bound;
good_range = chemical_profile(idx_bound,:) <= -0.95;
good = all(good_range, 1);
for i = 1 : nr
    if good(i)
        fprintf('dur=%2g B1max=%2g \n', grid_dur(i), grid_fa(i) )
    end
end

% end % fcn
