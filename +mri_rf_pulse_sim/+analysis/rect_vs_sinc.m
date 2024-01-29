function varargout = rect_vs_sinc()
% This function compares the RECT pulse, which is the simplest pulse,
% versus the SINC, which is probably the most used.


%% Parameters

% generate HS pulse with default paramters
RECT = mri_rf_pulse_sim.rf_pulse.rect();
SINC = mri_rf_pulse_sim.rf_pulse.sinc();

slice_thickness = 4/1000; % mm -> m
factor = 4; % to visualize larger than just the expected slice profile

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz = 1001;
solver.setSpatialPosition(linspace(-slice_thickness*factor,+slice_thickness*factor,n_dz));
solver.setDeltaB0(0); % in this exemple, assume no dB0


%% Computation

% pre-allocation
all_slice_profile = zeros(solver.SpatialPosition.N,3);
colors = lines(size(all_slice_profile,2));

% solve and store

solver.setPulse(RECT);
solver.solve();
all_slice_profile(:,1) = solver.getSliceProfilePerp();

solver.setPulse(SINC);
solver.solve();
all_slice_profile(:,2) = solver.getSliceProfilePerp();

SINC.set_window('hanning');
SINC.generate();
solver.solve(); % the solver already has a pointer to the pulse
all_slice_profile(:,3) = solver.getSliceProfilePerp();


%% Plot

fig = figure('Name',mfilename,'NumberTitle','off');

ax(1) = subplot(2,1,1);
ax(2) = subplot(2,1,2);

for i = 1 : length(ax)
    hold(ax(i), 'on');
    plot(ax(i), solver.SpatialPosition.getScaled(), all_slice_profile(:,1), 'Color', colors(1,:))
    plot(ax(i), solver.SpatialPosition.getScaled(), all_slice_profile(:,2), 'Color', colors(2,:))
    plot(ax(i), solver.SpatialPosition.getScaled(), all_slice_profile(:,3), 'Color', colors(3,:))
    xlabel(ax(i),'mm')
    ylabel(ax(i),'SliceProfile')
    % visual tips
    plot(ax(i), [-slice_thickness -slice_thickness]/2*solver.SpatialPosition.scale, [0 1], 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
    plot(ax(i), [+slice_thickness +slice_thickness]/2*solver.SpatialPosition.scale, [0 1], 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
    plot(ax(i), solver.SpatialPosition.getScaled(), ones(size(solver.SpatialPosition.getScaled())), 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
    legend(ax(i),{'RECT', 'SINC', 'SINC x hanning_window'}, 'Interpreter','none')
    axis(ax(i), 'tight')
end

% just for first subplot : zoom
xlim(ax(1),[-slice_thickness +slice_thickness]*solver.SpatialPosition.scale)


%% Output ?

if nargout
    varargout{1} = efficiency_table;
    varargout{2} = fig;
end


end % fcn
