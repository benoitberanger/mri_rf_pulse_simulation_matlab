function value = get_gamma(nuclei)
% gyromagnetic ratio in rad/T/s

if nargin < 1
    nuclei = '1H';
end

switch nuclei
    case '1H'
        mega_hertz_per_testla = 42.58;
    otherwise
        error('unknown nuclei')
end

value = 2*pi * mega_hertz_per_testla * 1e6;

end % fcn
