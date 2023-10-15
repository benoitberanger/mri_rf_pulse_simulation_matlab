classdef slr < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Shinnar-Le Roux

    properties (GetAccess = public, SetAccess = public)
        d1          mri_rf_pulse_sim.ui_prop.scalar                        % [] ripple ratio on the rect top      (from 0 to 1)
        d2          mri_rf_pulse_sim.ui_prop.scalar                        % [] ripple ratio on the rect baseline (from 0 to 1)
        TBWP        mri_rf_pulse_sim.ui_prop.scalar                        % [] TimeBandWidthProduct
        flip_angle  mri_rf_pulse_sim.ui_prop.scalar                        % [deg] flip angle
        pulse_type  mri_rf_pulse_sim.enum.slr_pulse_type                   % [enum]
        filter_type mri_rf_pulse_sim.enum.slr_filter_type                  % [enum]
    end % props

    properties (GetAccess = public, SetAccess = protected, Dependent)
        bandwidth                                                          % Hz
    end % props

    methods % no attribute for dependent properies
        function value = get.bandwidth(self)
            value = self.TBWP / self.duration;
        end
    end % meths

    methods (Access = public)

        % constructor
        function self = slr()
            self.d1         = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='d1'        , value=  0.01, unit='from 0 to 1');
            self.d2         = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='d2'        , value=  0.01, unit='from 0 to 1');
            self.TBWP       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='TBWP'      , value=  8                       );
            self.flip_angle = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='flip_angle', value=90    , unit='°'          );
            self.n_points.value = 64; % the number of points must be "balanced" for th PM algo to work
            self.pulse_type  = 'ex';
            self.filter_type = 'pm';
            self.generate_slr();
        end % fcn

        function generate(self)
            self.generate_slr();
        end % fcn

        % generate time, AM, FM, GM
        function generate_slr(self)

            self.time = linspace(-self.duration/2, +self.duration/2, self.n_points.get());
            self.GZ = ones(size(self.time)) * self.GZavg;
            
            [d1e, d2e] = effective_ripples(self.d1.get(), self.d2.get(), self.pulse_type);
            D = DinfLP(d1e, d2e);
            w = D / self.TBWP;
            % transition_band = self.bandwidth  * w;
            % normalized_transition_band = transition_band / self.bandwidth/2;
            % fbot = 0.5 - normalized_transition_band/2;
            % ftop = 0.5 + normalized_transition_band/2;

            freq_vector = [0, (1 - w) * (self.TBWP / 2), (1 + w) * (self.TBWP / 2), (self.n_points.get() / 2)]/self.n_points.get()*2;
            mag_vector  = [1 1 0 0];
            ripple_vector = [d1e d2e];
            b = firpm(self.n_points.get()-1, freq_vector, mag_vector, 1./ripple_vector);

            a = b2a(b);
            waveform = ab2rf(a,b);
            
            
            % [c, s] = inverseSLR(a, b);
            % theta = acos(c);
            % phi = -1j * log(s / sin(theta/2));
            % self.B1 = phi * exp(1j * theta);

            waveform = waveform / trapz(self.time, waveform); % normalize integral
            waveform = waveform * deg2rad(self.flip_angle.get()) / self.gamma; % scale integrale with flip angle
            self.B1 = waveform;

            % plot_cplx(self.B1);

        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('slr : ??=%s',...
                ' ');
        end % fcn

        function init_specific_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.d1 self.d2 self.TBWP self.flip_angle]...
                );
        end % fcn

    end % meths

    methods (Access = private)
    end % meths

    methods(Static)
    end

end % class

function [d1e, d2e] = effective_ripples(d1, d2, pulse_type)

switch pulse_type
    case 'st'
        d1e = d1;
        d2e = d2;
    case 'ex'
        d1e = sqrt(d1/2);
        d2e = d2/sqrt(2);
    case 'se'
        d1e = d1/4;
        d2e = sqrt(d2);
    case 'inv'
        d1e = d1/8;
        d2e = sqrt(d2/2);
    case 'sat'
        d1e = d1/2;
        d2e = sqrt(d2);
    otherwise
        error('pulse_type ?')
end
end % fcn

function D = DinfLP(d1, d2)
% D infinity for linear phase FIR filter
a1 = +5.309 * 1e-3;
a2 = +7.114 * 1e-2;
a3 = -4.761 * 1e-1;
a4 = -2.660 * 1e-3;
a5 = -5.941 * 1e-1;
a6 = -4.278 * 1e-1;
L1 = log10(d1);
L2 = log10(d2);
D = (a1*L1^2 + a2*L1 + a3)*L2 + (a4*L1^2 + a5*L1 + a6);
end % fcn

function a = b2a(b)
%%
n_pts = length(b);
padding = n_pts*16;

Bz = fft([b zeros(1,padding)]);
Bz_max = max(abs(Bz));
if Bz_max > 1
    Bz = Bz / (Bz_max + eps); % make sure new Bz_max < 1
end
Az_mag = sqrt(1-Bz.*conj(Bz));

Az = Az_mag .* exp(1j * imag(hilbert(log(Az_mag))));
% Az = mag2mp(Az_mag);
a = fft(Az);
a = a(1:n_pts);
a = fliplr(a);

% plot_cplx(Bz)

end

function a = mag2mp(x)
n = length(x);
xl = log(abs(x));
xlf = fft(xl);
xlfp = xlf;
xlfp(1) = xlf(1);
xlfp(2:n/2) = 2 * xlf(2:n/2);
xlfp(n/2) = xlf(n/2);
xlfp(n/2+1:n) = 0;
xlaf = ifft(xlfp);
a = exp(xlaf);
end

function rf = ab2rf(a,b)

n_pts = length(a);
rf = complex(zeros(1,n_pts));

for idx = n_pts-1 : -1 : 1
    cj = sqrt( 1 / ( 1 + abs(b(idx)/a(idx)).^2 ));
    sj = conj(cj * b(idx)/a(idx) );
    theta = 2 * atan2(abs(sj), cj);
    phi = angle(sj);
    rf(idx) = theta  * exp(1j * phi);

    if idx > 1
    at = cj*a + sj*b;
    bt = -conj(sj)*a +cj*b;
    a = at(2:idx+1);
    b = bt(1:idx);
    end

    % phi = 2 * atan2( abs(b(1)), abs(a(1)) );
    % theta = angle(-1j * b(1)/a(1));
    % rf(idx) = theta * exp(1j * phi);
    % 
    % c = cos(theta/2);
    % s = 1j * exp(1j * theta) * sin(theta/2);
    % prev_a = c*a +conj(s)*b;
    % prev_b = -s*a + c*b;
    % a = prev_a;
    % b = prev_b;
    
end

% plot_cplx(rf)

end 


function [c, s] = inverseSLR(a, b)
n = length(a) ;
c = zeros([1,n]) ;
s = zeros([1,n]) ;
aprev = zeros([1,n]) ;

for i = n :-1 :1
    norm = sqrt( conj(b(1)) * b(1) + conj(a(1)) * a(1)) ;
    cc = a(1) / norm ; ss = b(1) / norm ;
    aprev = conj(cc) * a + conj(ss) * b ;
    b = - ss * a + cc * b ;
    a(1 :(i-1)) = aprev(1 :(i-1)) ;
    b(1 :(i-1)) = b(2 :i) ;
    c(i) = cc ; s(i) =ss ;
end
end

function plot_cplx(in)
clf
subplot(4,1,1)
plot(real(in))
subplot(4,1,2)
plot(imag(in))
subplot(4,1,3)
plot(abs(in))
subplot(4,1,4)
plot(angle(in))
end
