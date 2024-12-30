function value = get_gamma(nuclei)
% gyromagnetic ratio in rad/T/s

if nargin < 1
    nuclei = '1H';
end

switch nuclei
    case   '1H' , mega_hertz_per_testla =  42.576;
    case   '2H' , mega_hertz_per_testla =   6.536;
    case   '3H' , mega_hertz_per_testla =  45.415;
    case   '3He', mega_hertz_per_testla = -32.434;
    case   '7Li', mega_hertz_per_testla =  16.546;
    case  '13C' , mega_hertz_per_testla =  10.708;
    case  '14N' , mega_hertz_per_testla =   3.077;
    case  '15N' , mega_hertz_per_testla =  -4.316;
    case  '17O' , mega_hertz_per_testla =  -5.772;
    case  '19F' , mega_hertz_per_testla =  40.078;
    case  '23Na', mega_hertz_per_testla =  11.262;
    case  '27Al', mega_hertz_per_testla =  11.103;
    case  '29Si', mega_hertz_per_testla =  -8.465;
    case  '31P' , mega_hertz_per_testla =  17.235;
    case  '57Fe', mega_hertz_per_testla =   1.382;
    case  '63Cu', mega_hertz_per_testla =  11.319;
    case  '67Zn', mega_hertz_per_testla =   2.669;
    case '129Xe', mega_hertz_per_testla = -11.776;

    otherwise
        error('unknown nuclei')
end

value = 2*pi * mega_hertz_per_testla * 1e6;

end % fcn
