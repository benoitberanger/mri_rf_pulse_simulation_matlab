function varargout = rf_clip()
% This funcion show that increasing the SINC duration reduce it's B1max, so
% reduce the maximu voltage.


%% Parameters

SINC = mri_rf_pulse_sim.rf_pulse.sinc();
SINC.n_points.set(256);
SINC.n_side_lobs.set(4);

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz = 301;
solver.setPulse(SINC);
solver.setSpatialPosition(linspace(-SINC.slice_thickness.get(),+SINC.slice_thickness.get(),n_dz));
solver.setDeltaB0(0); % in this exemple, assume no dB0
solver.setT1(0.800); % WM @ 3T
solver.setT2(0.080); % WM @ 3T

% Evaluate pulse shape and B1max (and check it's profile) with different durations
vect = 2 : 2 : 10; % ms
duration_range = mri_rf_pulse_sim.ui_prop.range(name='duration', vect=vect*1e-3, unit='ms', scale=1e3);
N = duration_range.N;


%% Computation

% pre-allocation
all_B1max         = zeros(                       1,N);
all_pulse_time    = zeros(SINC.n_points.get()     ,N);
all_pulse_shape   = zeros(SINC.n_points.get()     ,N);
all_slice_profile = zeros(solver.SpatialPosition.N,N);
colors = jet(N);

% solve and store
for i = 1 : N
    SINC.duration.set(duration_range.vect(i));
    SINC.generate();
    solver.solve();
    all_B1max        (1,i) = SINC.B1max* 1e6; % T -> µT
    all_pulse_time   (:,i) = SINC.time * 1e3; % s -> ms
    all_pulse_shape  (:,i) = SINC.real * 1e6; % T -> µT
    all_slice_profile(:,i) = solver.getSliceProfilePerp();
end


%% Plot

fig = figure('Name',mfilename,'NumberTitle','off');

ax(1) = subplot(3,1,1);
ax(2) = subplot(3,1,2);
ax(3) = subplot(3,1,3);
hold(ax, 'all')
colors = flipud(colors);

% data
for i = N : -1 : 1
    plot(ax(1), all_pulse_time(:,i)               , all_pulse_shape  (:,i), 'Color',colors(i,:), 'LineWidth',2);
    plot(ax(3), solver.SpatialPosition.getScaled(), all_slice_profile(:,i), 'Color',colors(i,:), 'LineWidth',2);
    plot(ax(2), vect(i), all_B1max(i), 'MarkerFaceColor',colors(i,:), 'MarkerEdgeColor','black', 'Marker', 's', 'MarkerSize', 10, 'LineStyle','none');
end
plot(ax(2), vect, all_B1max, 'Color','black', 'LineStyle',':')

%visual tips
plot(ax(3), solver.SpatialPosition.getScaled(), ones(size(solver.SpatialPosition.getScaled())), 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)

labels = string(duration_range.getScaled()) + "ms";
labels = flip(labels);

xlabel(ax(1),'time (ms)')
ylabel(ax(1),'Real (µT)')
axis(ax(1), 'tight')
legend(ax(1), labels)

xlabel(ax(2),'duration (ms)')
ylabel(ax(2),'B1max (µT)')
axis(ax(2), 'tight')
legend(ax(2), labels)

xlabel(ax(3),'spatial position (mm)')
ylabel(ax(3),'slice profile (M\perp)')
axis(ax(3), 'tight')
legend(ax(3), labels)


%% Output ?

if nargout
    varargout{1} = fig;
end


end % fcn
