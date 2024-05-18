%function slice_selection_rewinder_lob()
%% GZ_REWINDER : why do we need a slice selection gradient rewinder ?
%
% This function shows the effect of slice selection gradient rewinder
% on the "phase" of the transverse magnetization

close all
clear
clc


%% Parameters

SINC = mri_rf_pulse_sim.rf_pulse.sinc();
SINC.n_side_lobs.set(5);    % for a sharper slice profile
SINC.set_window('hanning'); % add apodization so the profile looks more smooth
SINC.rf_phase.set(180);     % so magnetization will be on +y instead of -y ---> mostly for the plots

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
solver.setPulse(SINC);
n_dz = 501;
solver.setSpatialPosition(linspace(-SINC.slice_thickness.get(),+SINC.slice_thickness.get(),n_dz));
solver.setDeltaB0(0); % in this example, assume no dB0


%% Computation

SINC.gz_rewinder.setFalse();
SINC.generate();
solver.solve();
rew0_x = solver.getSliceProfile('x');
rew0_y = solver.getSliceProfile('y');
rew0_z = solver.getSliceProfile('z');

SINC.gz_rewinder.setTrue();
SINC.generate();
solver.solve();
rew1_x = solver.getSliceProfile('x');
rew1_y = solver.getSliceProfile('y');
rew1_z = solver.getSliceProfile('z');


%% Plot

fig = figure(Name=sprintf('[%s]', mfilename), NumberTitle='off', Units='pixels', Position=[100 100 1600 800]);
ax(1) = subplot(1,2,1, 'Parent',fig);
ax(2) = subplot(1,2,2, 'Parent',fig);
title(ax(1), 'no rewinder')
title(ax(2), 'with rewinder')
hold(ax, 'all')

slice_eval = solver.SpatialPosition.getScaled();
slice_eval = slice_eval(:);

q1 = quiver3(ax(1), ...
    zeros(size(slice_eval)), zeros(size(slice_eval)), slice_eval, ...
    rew0_x, rew0_y, rew0_z);
q2 = quiver3(ax(2), ...
    zeros(size(slice_eval)), zeros(size(slice_eval)), slice_eval, ...
    rew1_x, rew1_y, rew1_z);

q1.ShowArrowHead = 'off';
q2.ShowArrowHead = 'off';
q1.AutoScale = 'off';
q2.AutoScale = 'off';
view(ax, 3)
axis(ax, 'tight')

%end % fcn
