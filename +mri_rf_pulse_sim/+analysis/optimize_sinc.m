function optimize_sinc()
%% What is the best SINC quality for a given B1max ?
% Here we keep the FlipAngle of the pulse.
% Choice 1 : To increase pulse "quality" while keeping the same duration, we need to increase it's bandwidth, so it's B1max.
% Choice 2 : To reduce pulse duration while keeping the same quality, we need to increase it's B1max.


%% Parameters

% input parameters
target_B1max = 15e-6; % 15 µT is a classic constrain for pulses

% generate default pulse, using Hanning window (mostly for visualization)
SINC_base          = mri_rf_pulse_sim.rf_pulse.sinc(); SINC_base.         set_window('hanning');
SINC_opti_quality  = mri_rf_pulse_sim.rf_pulse.sinc(); SINC_opti_quality. set_window('hanning');
SINC_opti_duration = mri_rf_pulse_sim.rf_pulse.sinc(); SINC_opti_duration.set_window('hanning');
PULSES = [SINC_base, SINC_opti_quality, SINC_opti_duration];
nPULSE = length(PULSES);
COLORS = lines(nPULSE);

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz = 301;
solver.setSpatialPosition(linspace(-SINC_base.slice_thickness.get(),+SINC_base.slice_thickness.get(),n_dz));
solver.setDeltaB0(0); % in this example, assume no dB0
solver.setT1(0.800); % WM @ 3T
solver.setT2(0.080); % WM @ 3T
% add some relaxation to better visualize the slice profile of the different pulses

fig_size_px = [100 100 1600 800];


%% Computation

% generate base pulse
SINC_base.generate();
SINC_base.time = SINC_base.time - SINC_base.time(1); % start to t=0ms
solver.setPulse(SINC_base);
solver.solve();
slice_profile(1,:) = solver.getSliceProfilePerp();
current_B1max = SINC_base.B1max.get();

% optimize pulse quality
current_TBWP  = SINC_base.tbwp .get();
new_TBWP = target_B1max/current_B1max * current_TBWP;
SINC_opti_quality.n_side_lobs.set(new_TBWP/2); % for SCINC, TBWP = 2*n_side_lob = n_zero_crossings
SINC_opti_quality.generate();
SINC_opti_quality.time = SINC_opti_quality.time - SINC_opti_quality.time(1); % start to t=0ms
solver.setPulse(SINC_opti_quality);
solver.solve();
slice_profile(2,:) = solver.getSliceProfilePerp();

% optimize pulse duration
current_duration = SINC_base.duration.get();
new_duration = current_duration / (target_B1max/current_B1max);
SINC_opti_duration.duration.set(new_duration);
SINC_opti_duration.generate();
SINC_opti_duration.time = SINC_opti_duration.time - SINC_opti_duration.time(1); % start to t=0ms
solver.setPulse(SINC_opti_duration);
solver.solve();
slice_profile(3,:) = solver.getSliceProfilePerp();


%% Plot

fig1 = figure(Name=sprintf('[%s]: plot pulses', mfilename), NumberTitle='off', Units='pixels', Position=fig_size_px);
for i = 1 : nPULSE
    p(i) = uipanel(Parent=fig1, Units="normalized",Position=[(i-1)*1/nPULSE 0.00 1/nPULSE 1.00], Title=PULSES(i).summary);
    axes(p(i))
    time = PULSES(i).time*PULSES(i).duration.scale;

    ax_mag(i) = subplot(2,1,1);
    plot(ax_mag(i), time, PULSES(i).real*PULSES(i).B1max.scale, 'LineWidth',2, 'Color',COLORS(i,:))
    title('RF')
    xlabel('time (ms)')
    ylabel('µT')

    ax_gz(i) = subplot(2,1,2);
    plot(ax_gz(i), time, PULSES(i).GZ*PULSES(i).GZmax.scale   , 'LineWidth',2, 'Color',COLORS(i,:))
    title('Gradient')
    xlabel('time (ms)')
    ylabel('mT/m')
end
linkaxes([ax_mag ax_gz], 'x')
linkaxes(ax_mag, 'y')
linkaxes(ax_gz , 'y')

fig2 = figure(Name=sprintf('[%s]: plot slice profiles', mfilename), NumberTitle='off', Units='pixels', Position=fig_size_px);
ax = axes(fig2);
hold(ax,'on');
spatial_position_all = solver.SpatialPosition.getScaled();
% plot slice profiles
for i = 1 : nPULSE
    plot(ax, spatial_position_all, slice_profile(i,:), 'LineWidth',2, 'Color',COLORS(i,:))
end
% plot some visual tips
plot(ax, [-1 -1]*SINC_base.slice_thickness/2*1000, [0 1], 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
plot(ax, [+1 +1]*SINC_base.slice_thickness/2*1000, [0 1], 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
xlabel(ax,'spatial position (mm)')
ylabel(ax,'slice profile (M\perp)')
axis  (ax,'tight')
legend(ax, {'SINC base', 'SINC opti quality', 'SINC opti duration'})


end % fcn
