function slice_selection_rewinder_lob()
%% GZ_REWINDER : why do we need a slice selection gradient rewinder ?
%
% This function shows the effect of slice selection gradient rewinder
% on the "phase" of the transverse magnetization


%% Parameters

SINC = mri_rf_pulse_sim.rf_pulse.sinc();
SINC.n_side_lobs.set(3);    % for a sharper slice profile
SINC.window.set('hanning'); % add apodisation so the profile looks more smooth
SINC.rf_phase.set(180);     % so magnetization will be on +y instead of -y ---> mostly for the plots

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(SINC);
n_dz = 501;
solver.setSpatialPosition(linspace(-SINC.slice_thickness*1.5,+SINC.slice_thickness*1.5,n_dz));
solver.setDeltaB0(0); % in this example, assume no delta B0


%% Computation

SINC.gz_rewinder.setFalse();
SINC.generate();
solver.solve();
Mx_rewind0 = solver.getSliceProfile('x'   );
My_rewind0 = solver.getSliceProfile('y'   );
Mp_rewind0 = solver.getSliceProfile('perp');

SINC.gz_rewinder.setTrue();
SINC.generate();
solver.solve();
Mx_rewind1 = solver.getSliceProfile('x'   );
My_rewind1 = solver.getSliceProfile('y'   );
Mp_rewind1 = solver.getSliceProfile('perp');


%% Plot

fig = figure(Name=sprintf('[%s]', mfilename), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);
ax(1) = subplot(1,2,1, 'Parent',fig);
ax(2) = subplot(1,2,2, 'Parent',fig);
title(ax(1), 'no rewinder'  )
title(ax(2), 'with rewinder')
hold (ax   , 'all'          )

SpatialPosition = solver.SpatialPosition.getScaled();
common_line_props = {'LineWidth', 2};

plot(ax(1), SpatialPosition, Mx_rewind0, 'DisplayName', 'M_x'  , common_line_props{:})
plot(ax(1), SpatialPosition, My_rewind0, 'DisplayName', 'M_y'  , common_line_props{:})
plot(ax(1), SpatialPosition, Mp_rewind0, 'DisplayName', 'M_x_y', common_line_props{:}, 'LineStyle', ':', 'Color', 'Magenta')
plot(ax(2), SpatialPosition, Mx_rewind1, 'DisplayName', 'M_x'  , common_line_props{:})
plot(ax(2), SpatialPosition, My_rewind1, 'DisplayName', 'M_y'  , common_line_props{:})
plot(ax(2), SpatialPosition, Mp_rewind1, 'DisplayName', 'M_x_y', common_line_props{:}, 'LineStyle', ':', 'Color', 'Magenta')

xlabel(ax,'Spatial position (mm)')
ylim  (ax, [-1 +1])

legend(ax(1))
legend(ax(2))


end % fcn
