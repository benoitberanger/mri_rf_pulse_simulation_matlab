function s = get_fig_pos(use_onfig)

if nargin == 0
    use_onfig = false;
end

s = struct;

if use_onfig
    x0 = 0.00;
    y0 = 0.00;
else
    x0 = 0.02;
    y0 = 0.05;
end
x1 = 1 - x0*2;
y1 = 1 - y0*2;

pulse_definition      = [0.00  0.20  0.40  0.80];
simulation_parameters = [0.00  0.00  0.40  0.20];
simulation_results    = [0.40  0.00  0.60  1.00];
window                = [0.20  0.50  0.20  0.30];

s.pulse_definition      = (pulse_definition      + [x0 y0 0 0]) .* [1 1 x1 y1];
s.simulation_parameters = (simulation_parameters + [x0 y0 0 0]) .* [1 1 x1 y1];
s.simulation_results    = (simulation_results    + [x0 y0 0 0]) .* [1 1 x1 y1];
s.window                = (window                + [x0 y0 0 0]) .* [1 1 x1 y1];

end % fcn
