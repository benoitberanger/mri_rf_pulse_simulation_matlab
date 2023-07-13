function s = get_fig_pos()

s = struct;

x0 = 0.02;
x1 = 1 - x0*2;
y0 = 0.05;
y1 = 1 - y0*2;

pulse_definition      = [0.0  0.2  0.3  0.8];
simulation_parameters = [0.0  0.0  0.3  0.2];
simulation_results    = [0.3  0.0  0.7  1.0];

s.pulse_definition      = (pulse_definition      + [x0 y0 0 0]) .* [1 1 x1 y1];
s.simulation_parameters = (simulation_parameters + [x0 y0 0 0]) .* [1 1 x1 y1];
s.simulation_results    = (simulation_results    + [x0 y0 0 0]) .* [1 1 x1 y1];

end % fcn
