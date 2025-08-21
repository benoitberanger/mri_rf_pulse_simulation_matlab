function optimize_FatSat_pulse_3T()
%% Are the default parameters of the FatSut pulse for cmrr_mbep2d* sequence optimal ?


%% Settings

B0      = 2.89; % [T]  , Siemens 7T magnets

ppm_fat = -3.3; % [ppm], default Fat frequency offset on Siemens scanners

% generate pulse
pulse = mri_rf_pulse_sim.rf_pulse.gaussian();
pulse.n_points.set(64);         % waveform is simple, save computation time
base_freq_offset = ppm_fat*1e-6 * pulse.gamma/(2*pi) * B0; % Hz
pulse.slice_thickness.set(Inf); % non-selective pulse
pulse.duration.set(5.120e-3);   % cmrr_mbep2d_* setting, hardcoded parameters
pulse.flip_angle.set(110);      % default FA for cmrr_mb_*, available in the Sequence > Special
pulse.frequency_offcet.set(base_freq_offset);

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(pulse);
solver.setSpatialPosition(0); % non-selective pulse
solver.setB0(B0);
solver.T1.setScaled(1300); % GM @ 3T
solver.T2.setScaled(80);   % WM @ 3T
n_db0 = 301;
solver.setDeltaB0(linspace(-ppm_fat*2,+ppm_fat,n_db0)*1e-6);

[~,idx_water] = min(abs(solver.DeltaB0.vect               ));
[~,idx_fat  ] = min(abs(solver.DeltaB0.vect - ppm_fat*1e-6));


%% Computation

eval_fa =     0 :  5 :   180; % deg
eval_df = -1000 : 10 : +1000; % Hz

[grid_fa, grid_df] = ndgrid(eval_fa, eval_df);
nr = numel(grid_fa);

Mpara_water = zeros(size(grid_fa));
Mperp_fat   = zeros(size(grid_fa));

t0 = tic;
for i = 1 : nr
    if mod(i,100) == 0
        fprintf('sim : %d/%d \n', i, nr)
    end
    pulse.flip_angle      .set(                   grid_fa(i));
    pulse.frequency_offcet.set(base_freq_offset + grid_df(i))
    pulse.generate()
    solver.solve()

    chemical_profile_para = solver.getChemicalShiftPara();
    chemical_profile_perp = solver.getChemicalShiftPerp();
    Mpara_water(i) = chemical_profile_para(idx_water);
    Mperp_fat  (i) = chemical_profile_perp(idx_fat  );
end
t1 = toc(t0);
fprintf('sim took %gs \n', t1)


%% Plot

f = figure(Name=sprintf('[%s]', mfilename), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);
ax = axes(f);
hold(ax, 'on')

contour(ax,grid_fa,grid_df,Mperp_fat  ,  0.1:0.2:1                        , 'ShowText','on', 'LineStyle', '--');
contour(ax,grid_fa,grid_df,Mpara_water, [0.1:0.1:0.9 0.95 0.98 0.99 0.999], 'ShowText','on', 'LineStyle', '-' );
legend({ ...
    'Fat signal suppressed : Higher is better', ...
    'Water signal reserve  : Higher is better' ...
    }, ...
    'Location','best')
colormap('jet')

xlabel(ax,'FA (°)')
ylabel(ax,'dF from fat (Hz)')

yyaxis(ax,'right')
eval_ppm = (eval_df+base_freq_offset) * 2*pi / (solver.rf_pulse.gamma * solver.B0) * 1e6;
ylim(ax,[min(eval_ppm) max(eval_ppm)])
ylabel(ax,'dF from water(ppm)')


end % fcn
