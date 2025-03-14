function sinc_n_lob()
%% SINC : how to choose the number of lobs ?
%
% This function shows the effet of number of side lobs of the SINC, keep all other parameters constant.


%% Parameters

SINC = mri_rf_pulse_sim.rf_pulse.sinc();
SINC.n_points.set(256);

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz = 301;
solver.setPulse(SINC);
solver.setSpatialPosition(linspace(-SINC.slice_thickness.get()*1.5,+SINC.slice_thickness.get()*1.5,n_dz));
solver.setDeltaB0(0); % in this example, assume no dB0

% number of side lobs : TBWP = 2*n_side_lob
n_side_lobs = [1 2 4 6];
N = length(n_side_lobs);


%% Computation

% pre-allocation
all_pulse_shape   = zeros(SINC.n_points.get()     ,N);
all_slice_profile = zeros(solver.SpatialPosition.N,N);
colors = jet(N);
stats = struct;

% solve and store
for i = 1 : N
    SINC.n_side_lobs.set(n_side_lobs(i));
    SINC.generate();
    solver.solve();
    all_pulse_shape  (:,i) = SINC.real * 1e6; % T -> µT
    all_slice_profile(:,i) = solver.getSliceProfilePerp();

    stats(i).n_side_lobs  = SINC.n_side_lobs.get();
    stats(i).tbwp         = SINC.tbwp;
    stats(i).B1max_uT     = SINC.B1max * 1e6; % T   -> µT
    stats(i).GZavg_mTm    = SINC.GZavg * 1e3; % T/m -> mT/m
    stats(i).bandwidth_Hz = SINC.bandwidth;
end


%% Show stats

stat_table = struct2table(stats);
disp(stat_table)


%% Plot : the input SINC_with_x_side_lobs and its corresponding Slice Profile

fig = figure(Name=sprintf('[%s]', mfilename), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);

ax(1) = subplot(2,1,1, 'Parent',fig);
ax(2) = subplot(2,1,2, 'Parent',fig);
title(ax(1), 'SINC with n side lobs')
title(ax(2), 'Slice profile')
hold(ax, 'all')

for i = 1 : N
    plot(ax(1), SINC.time*1e3                     , all_pulse_shape  (:,i), 'Color',colors(i,:), 'LineWidth',2);
    plot(ax(2), solver.SpatialPosition.getScaled(), all_slice_profile(:,i), 'Color',colors(i,:), 'LineWidth',2);
end
linestyle_tips = {'LineStyle',':', 'Color','black', 'LineWidth', 0.5};
plot(ax(1), SINC.time*1e3, zeros(size(SINC.time)), linestyle_tips{:})
plot(ax(2), [-SINC.slice_thickness.get() -SINC.slice_thickness.get()]/2*solver.SpatialPosition.scale, [0 1], linestyle_tips{:})
plot(ax(2), [+SINC.slice_thickness.get() +SINC.slice_thickness.get()]/2*solver.SpatialPosition.scale, [0 1], linestyle_tips{:})

xlabel(ax(1),'time (ms)')
ylabel(ax(1),'µT')
axis  (ax(1),'tight')

xlabel(ax(2),'slice position (mm)')
ylabel(ax(2),'slice profile (M\perp)')
axis  (ax(2),'tight')

legend(ax(1), num2str(n_side_lobs(:)))
legend(ax(2), num2str(n_side_lobs(:)))


end % fcn
