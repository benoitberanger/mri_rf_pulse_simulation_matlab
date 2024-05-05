function rf_clip()
%% Too much B1max ? maybe increase pulse duration
% This function show that increasing the duration of a RECT reduce it's $B1_{max}$,
% so reduces the maximum voltage of the RF power amplifier.


%% Parameters

RECT = mri_rf_pulse_sim.rf_pulse.rect();

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz = 301;
solver.setPulse(RECT);
solver.setSpatialPosition(linspace(-RECT.slice_thickness.get(),+RECT.slice_thickness.get(),n_dz));
solver.setDeltaB0(0); % in this example, assume no dB0
solver.setT1(0.800); % WM @ 3T
solver.setT2(0.080); % WM @ 3T

% Evaluate pulse shape and B1max (and check it's profile) with different durations
vect = [2 4 6 8 10]; % ms
duration_range = mri_rf_pulse_sim.ui_prop.range(name='duration', vect=vect*1e-3, unit='ms', scale=1e3);
N = duration_range.N;


%% Computation

% pre-allocation
all_B1max         = zeros(                       1,N);
all_pulse_time    = zeros(RECT.n_points.get()     ,N);
all_pulse_shape   = zeros(RECT.n_points.get()     ,N);
all_slice_profile = zeros(solver.SpatialPosition.N,N);
colors = jet(N);

% solve and store
for i = 1 : N
    RECT.duration.set(duration_range.vect(i));
    RECT.generate();
    solver.solve();
    all_B1max        (1,i) = RECT.B1max* 1e6; % T -> µT
    all_pulse_time   (:,i) = RECT.time * 1e3; % s -> ms
    all_pulse_shape  (:,i) = RECT.mag  * 1e6; % T -> µT
    all_slice_profile(:,i) = solver.getSliceProfilePerp();
end


%% Plot
% In the SliceProfile plot, the $M_{\perp}$ reduction comes from $T2$ relaxtion,
% which is not neglected in this simulation

fig = figure(Name=sprintf('[%s]', mfilename), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);
ax(1) = subplot(3,1,1, 'Parent',fig);
ax(2) = subplot(3,1,2, 'Parent',fig);
ax(3) = subplot(3,1,3, 'Parent',fig);
hold(ax, 'all')
colors = flipud(colors);

% data
for i = N : -1 : 1 % reverse plot order so the lowest duration is on top
    plot(ax(1), [all_pulse_time(1,i); all_pulse_time(:,i); all_pulse_time(end,i)], [0; all_pulse_shape(:,i); 0], 'Color',colors(i,:), 'LineWidth',2);
    plot(ax(3), solver.SpatialPosition.getScaled()                               ,   all_slice_profile(:,i)    , 'Color',colors(i,:), 'LineWidth',2);
    plot(ax(2), vect(i), all_B1max(i), 'MarkerFaceColor',colors(i,:), 'MarkerEdgeColor','black', 'Marker', 's', 'MarkerSize', 10, 'LineStyle','none');
end
plot(ax(2), vect, all_B1max, 'Color','black', 'LineStyle',':')

%visual tips
plot(ax(1), [min(all_pulse_time(:)) max(all_pulse_time(:))], [0 0]                                         , 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
plot(ax(3), solver.SpatialPosition.getScaled()             , ones(size(solver.SpatialPosition.getScaled())), 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)

labels = string(duration_range.getScaled()) + "ms";
labels = flip(labels); % because of reveres order in the plot

xlabel(ax(1),'time (ms)')
ylabel(ax(1),'Magnitude (µT)')
axis  (ax(1),'tight')
legend(ax(1), labels)

xlabel(ax(2),'duration (ms)')
ylabel(ax(2),'B1max (µT)')
axis  (ax(2),'tight')
legend(ax(2), labels)

xlabel(ax(3),'spatial position (mm)')
ylabel(ax(3),'slice profile (M\perp)')
axis  (ax(3),'tight')
legend(ax(3), labels)


end % fcn
