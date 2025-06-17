function optimize_NSel_HSn_7T()
%% Optimization of HSn pulse for 7T.
% We will look for a range of parameters that have a certain inversion
% efficiency, taking into account relaxation.


%% Parameters

% target inversion efficiency
target_Mz = -0.95;

% evaluate pulse chemical shift profile in this ppm range
target_range_db0 = 5; % ppm

% range of evaluated values
eval_dur   = [3 5 7 10 12]; % ms
eval_bw    = [500 1000 2000 3000 4000 6000 8000 10000 15000 20000]; % Hz
eval_n     = [1 2 4 6 8 10]; % HS<n> factor
eval_b1max = 10 : 2 : 20; % uT


%% Setup

% set base paramters of the pulse
pulse = mri_rf_pulse_sim.rf_pulse.goia.goia_hs();
pulse.slice_thickness.set(Inf); % set non-selective pulse

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(pulse);
solver.setSpatialPosition(0); % non-selective pulse, don't look at off-center effects
solver.setB0(6.98);           % Siemens 7T B0 field
solver.T1.setScaled(1450);    % WM @ 7T
solver.T2.setScaled(50);      % WM @ 7T
n_db0 = 301;
solver.setDeltaB0(linspace(-target_range_db0,+target_range_db0,n_db0)*1e-6);


%% Computation

[grid_dur, grid_bw, grid_n, grid_b1] = ndgrid(eval_dur,eval_bw, eval_n, eval_b1max);
nr = numel(grid_bw);

chemical_profile = zeros(solver.DeltaB0.N,nr);
for i = 1 : nr
    pulse.duration.set(grid_dur(i)*1e-3)
    pulse.bw.set(grid_bw(i))
    pulse.n.set(grid_n(i))
    pulse.b1max.set(grid_b1(i)*1e-6)
    pulse.generate()
    solver.solve()
    chemical_profile(:, i) = solver.getChemicalShiftPara();
end


%% Print

lower_bound = solver.DeltaB0.getScaled() >= -target_range_db0/2;
upper_bound = solver.DeltaB0.getScaled() <= +target_range_db0/2;
idx_bound = lower_bound & upper_bound;
good_range = chemical_profile(idx_bound,:) <= target_Mz;
good = all(good_range, 1);
for i = 1 : nr
    if good(i)
        fprintf('dur=%2g bw=%5g N=%2g B1max=%5.1f \n', grid_dur(i), grid_bw(i), grid_n(i), grid_b1(i) )
    end
end


end % fcn
