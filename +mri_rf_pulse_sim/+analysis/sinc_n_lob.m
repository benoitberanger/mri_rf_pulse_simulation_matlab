function varargout = sinc_n_lob()
% This function compares shows the effet of number of side lobs of the
% SINC, keep all other parameters constant.


%% Parameters

SINC = mri_rf_pulse_sim.rf_pulse.sinc();
SINC.n_points.set(256);

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz = 301;
solver.setPulse(SINC);
solver.setSpatialPosition(linspace(-SINC.slice_thickness.get(),+SINC.slice_thickness.get(),n_dz));
solver.setDeltaB0(0); % in this example, assume no dB0

% number of side lobs : TBWP = 2*n_side_lob
n_side_lob = [1 2 4 6 8 10];
N = length(n_side_lob);


%% Computation

% pre-allocation
all_pulse_shape   = zeros(SINC.n_points.get()     ,N);
all_slice_profile = zeros(solver.SpatialPosition.N,N);
colors = jet(N);

% solve and store
for i = 1 : N
    SINC.n_side_lobs.set(n_side_lob(i));
    SINC.generate();
    solver.solve();
    all_pulse_shape  (:,i) = SINC.real * 1e6; % T -> µT
    all_slice_profile(:,i) = solver.getSliceProfilePerp();
end


%% Plot

fig = figure('Name',mfilename,'NumberTitle','off');

ax(1) = subplot(2,1,1);
ax(2) = subplot(2,1,2);
hold(ax, 'all')
for i = 1 : N
    plot(ax(1), SINC.time*1e3                     , all_pulse_shape  (:,i), 'Color',colors(i,:), 'LineWidth',2);
    plot(ax(2), solver.SpatialPosition.getScaled(), all_slice_profile(:,i), 'Color',colors(i,:), 'LineWidth',2);
end
plot(ax(1), SINC.time*1e3, zeros(size(SINC.time)), 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
plot(ax(2), [-SINC.slice_thickness.get() -SINC.slice_thickness.get()]/2*solver.SpatialPosition.scale, [0 1], 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
plot(ax(2), [+SINC.slice_thickness.get() +SINC.slice_thickness.get()]/2*solver.SpatialPosition.scale, [0 1], 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
xlabel(ax(1),'time (ms)')
ylabel(ax(1),'µT')
axis(ax(1), 'tight')
xlabel(ax(2),'slice position (mm)')
ylabel(ax(2),'slice profile (M\perp)')
axis(ax(2), 'tight')
legend(ax(1), num2str(n_side_lob(:)))
legend(ax(2), num2str(n_side_lob(:)))


%% Output ?

if nargout
    varargout{1} = fig;
end


end % fcn
