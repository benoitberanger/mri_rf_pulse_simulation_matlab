function rect_vs_sinc()
%% Why SINC is used for slice selection instead of to RECT ?
%
% This function compares :
%
% * RECT, the "simplest" pulse
% * SINC, probably the most used
% * SINC x hanning, the same SINC modulated with a Hanning window.
%
% All these pulses have the *same* input parameters : duration, slice thickness, flip angle
%


%% Parameters

% generate pulses
RECT  = mri_rf_pulse_sim.rf_pulse.rect();
SINC  = mri_rf_pulse_sim.rf_pulse.sinc();
SINCh = mri_rf_pulse_sim.rf_pulse.sinc(); SINCh.window.set('hanning'); SINCh.generate();

slice_thickness = 4/1000; % mm -> m
slice_profile_visu_factor = 4; % to visualize larger than just the expected slice profile
fig_size_px = [100 100 1600 800];

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz = 1001;
solver.setSpatialPosition(linspace(-slice_thickness*slice_profile_visu_factor,+slice_thickness*slice_profile_visu_factor,n_dz));
solver.setDeltaB0(0); % in this example, assume no dB0


%% Plot pulses

fig1 = figure(Name=sprintf('[%s]: plot pulses', mfilename), NumberTitle='off', Units='pixels', Position=fig_size_px);
p1 = uipanel(Parent=fig1, Units="normalized",Position=[0.00 0.00 0.33 1.00], Title=RECT .summary);
p2 = uipanel(Parent=fig1, Units="normalized",Position=[0.33 0.00 0.33 1.00], Title=SINC .summary);
p3 = uipanel(Parent=fig1, Units="normalized",Position=[0.66 0.00 0.33 1.00], Title=SINCh.summary);

RECT. plot(p1);
SINC. plot(p2);
SINCh.plot(p3);


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

solver.setPulse(SINCh);
solver.solve();
all_slice_profile(:,3) = solver.getSliceProfilePerp();


%% Plot slice profiles

fig2 = figure(Name=sprintf('[%s]: plot slice profiles', mfilename), NumberTitle='off', Units='pixels', Position=fig_size_px);

ax(1) = subplot(2,1,1, 'Parent',fig2);
ax(2) = subplot(2,1,2, 'Parent',fig2);
title(ax(1), 'Zoom on expected SliceThickness')
title(ax(2), 'Zoom out from expected SliceThickness')

spatial_position_all = solver.SpatialPosition.getScaled();

for i = 1 : length(ax)
    hold(ax(i), 'on');
    plot(ax(i), spatial_position_all, all_slice_profile(:,1), 'Color', colors(1,:), 'LineWidth',2)
    plot(ax(i), spatial_position_all, all_slice_profile(:,2), 'Color', colors(2,:), 'LineWidth',2)
    plot(ax(i), spatial_position_all, all_slice_profile(:,3), 'Color', colors(3,:), 'LineWidth',2)
    xlabel(ax(i),'mm')
    ylabel(ax(i),'slice profile (M\perp)')
    % visual tips
    linestyle_tips = {'LineStyle',':', 'Color','black', 'LineWidth', 0.5};
    plot(ax(i), [-slice_thickness -slice_thickness]/2*solver.SpatialPosition.scale, [0 1], linestyle_tips{:})
    plot(ax(i), [+slice_thickness +slice_thickness]/2*solver.SpatialPosition.scale, [0 1], linestyle_tips{:})
    plot(ax(i), spatial_position_all, ones(size(spatial_position_all))                   , linestyle_tips{:})
    legend(ax(i),{'RECT', 'SINC', 'SINC x hanning_window'}, 'Interpreter','none')
    axis(ax(i), 'tight')
end

% just for first subplot : zoom on expected slice profile
xlim(ax(1),[-slice_thickness +slice_thickness]*solver.SpatialPosition.scale)


end % fcn
