function optimize_sinc()
%% What is the best SINC quality for a given B1max ?
% Here we keep the FlipAngle and the Duration of the pulse. To increase
% pulse "quality" we need to increase it's bandwidth.


%% Parameters

% input paramters
target_B1max = 15e-6; % 15 µT is a classic constrain for pulses

% generate default pulse, using Hanning window (mostly for visualization)
SINC_base = mri_rf_pulse_sim.rf_pulse.sinc(); SINC_base.set_window('hanning');
SINC_opti = mri_rf_pulse_sim.rf_pulse.sinc(); SINC_opti.set_window('hanning');

% set parameters of the solver
solver = mri_rf_pulse_sim.bloch_solver();
n_dz = 301;
solver.setSpatialPosition(linspace(-SINC_base.slice_thickness.get(),+SINC_base.slice_thickness.get(),n_dz));
solver.setDeltaB0(0); % in this example, assume no dB0

fig_size_px = [100 100 1600 800];


%% Computation

% generate base pulse
SINC_base.generate();
solver.setPulse(SINC_base);
solver.solve();
slice_profile_base = solver.getSliceProfilePerp();

% now optimize the pulse
current_B1max = SINC_base.B1max.get();
current_TBWP  = SINC_base.tbwp .get();
new_TBWP = target_B1max/current_B1max * current_TBWP;
SINC_opti.n_side_lobs.set(new_TBWP/2); % for SCINC, TBWP = 2*n_side_lob = n_zero_crossings
SINC_opti.generate();
solver.setPulse(SINC_opti);
solver.solve();
slice_profile_opti = solver.getSliceProfilePerp();


%% Plot

fig1 = figure(Name=sprintf('[%s]: plot pulses', mfilename), NumberTitle='off', Units='pixels', Position=fig_size_px);
p1 = uipanel(Parent=fig1, Units="normalized",Position=[0.00 0.00 0.50 1.00], Title=SINC_base.summary);
p2 = uipanel(Parent=fig1, Units="normalized",Position=[0.50 0.00 0.50 1.00], Title=SINC_opti.summary);
SINC_base.plot(p1);
SINC_opti.plot(p2);

fig2 = figure(Name=sprintf('[%s]: plot slice profiles', mfilename), NumberTitle='off', Units='pixels', Position=fig_size_px);
ax = axes(fig2);
hold(ax,'on');
spatial_position_all = solver.SpatialPosition.getScaled();
% plot slice profiles
plot(ax, spatial_position_all, slice_profile_base, 'LineWidth',2)
plot(ax, spatial_position_all, slice_profile_opti, 'LineWidth',2)
% plot some visual tips
plot(ax, [-1 -1]*SINC_base.slice_thickness/2*1000, [0 1], 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
plot(ax, [+1 +1]*SINC_base.slice_thickness/2*1000, [0 1], 'LineStyle',':', 'Color','black', 'LineWidth', 0.5)
xlabel(ax,'spatial position (mm)')
ylabel(ax,'slice profile (M\perp)')
axis  (ax,'tight')
legend(ax, {'SINC base', 'SINC opti'})


end % fcn
