function value = get_gamma(nuclei)
% gyromagnetic ratio in rad/T/s

if nargin < 1
    nuclei = '1H';
end

switch nuclei
    case '1H'
        value = 2*pi * 42.58 * 1e6;
    otherwise
        error('unknown nuclei')
end

end % fcn
