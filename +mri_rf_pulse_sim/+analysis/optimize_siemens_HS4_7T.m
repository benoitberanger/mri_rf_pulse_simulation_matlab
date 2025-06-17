function optimize_siemens_HS4_7T()
%% Optimization of Siemens HS4 pulse for 7T.
% We will look for a range of parameters that have a certain inversion
% efficiency, taking into account relaxation.


%% Parameters

% traget inversion efficiency
target_Mz = -0.95;

% evaluate pulse chemical shift profile in this ppm range
target_range_db0 = 5; % ppm

% range of evaluated values
eval_dur = [3 5 7 10 12];  % ms -> longer pulses have more T2 relaxation
eval_fa  = 100 : 50 : 900; % Siemens FlipAngle scaling == B1 peak scaling == Voltage peak scaling


%% Setup

% set base paramters of the pulse
location = fullfile(fileparts(mri_rf_pulse_sim.get_package_dir()), 'vendor', 'siemens');
fname = 'extrf.dat';
pulse = mri_rf_pulse_sim.rf_pulse.SIEMENS( ...
    file_path=fullfile(location,fname), ...
    pulse_name="IR12800H180/IR180_HS4" ...
    );
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

[grid_dur, grid_fa] = ndgrid(eval_dur, eval_fa);
nr = numel(grid_dur);

chemical_profile = zeros(solver.DeltaB0.N,nr);
b1max            = zeros(               1,nr);
for i = 1 : nr
    pulse.duration.set(grid_dur(i)*1e-3)
    pulse.flip_angle.set(grid_fa(i))
    pulse.generate()
    b1max(i) = pulse.B1max.getScaled();
    solver.solve()
    chemical_profile(:, i) = solver.getChemicalShiftPara();
end


%% Print

lower_bound = solver.DeltaB0.getScaled() >= -target_range_db0/2;
upper_bound = solver.DeltaB0.getScaled() <= +target_range_db0/2;
idx_bound = lower_bound & upper_bound;
good_range = chemical_profile(idx_bound,:) <= target_Mz;
good = all(good_range, 1);

fig = figure(Name=sprintf('[%s]', mfilename), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);
ax = axes(fig);
hold(ax,'on')

maxb1val = 50; % uT, for display
my_colors = jet(maxb1val);

for i = nr : -1 : 1
    
    if good(i)
        fprintf('dur=%2g ms  FA=%2g deg  B1max=%5.1f uT \n', grid_dur(i), grid_fa(i) , b1max(i))
        if b1max(i) >= maxb1val
            color = my_colors(end,:);
        else
            color = my_colors(round(b1max(i)),:);
        end
        plot(ax, grid_dur(i), grid_fa(i), Marker="o", MarkerSize=round(b1max(i)), MarkerFaceColor=color,MarkerEdgeColor='black')
        text(grid_dur(i), grid_fa(i), sprintf('%d', round(b1max(i))))
    else
        plot(ax, grid_dur(i), grid_fa(i), Marker="x", MarkerSize=5, Color='black')
    end
end

xlim([0 15])
xticks(eval_dur)
xlabel('duration (ms)')
ylabel('flip angle (°)')

colormap(ax,my_colors)
cb = colorbar();
cb.TickLabels = cellstr(num2str(round(cb.Ticks'*maxb1val)));


end % fcn
