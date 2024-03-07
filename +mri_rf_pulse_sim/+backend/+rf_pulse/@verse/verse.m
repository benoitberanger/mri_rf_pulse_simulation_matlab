classdef (Abstract) verse < handle
    % Steven Conolly, Dwight Nishimura, Albert Macovski, Gary Glover,
    % Variable-rate selective excitation, Journal of Magnetic Resonance
    % (1969), Volume 78, Issue 3, 1988, Pages 440-458, ISSN 0022-2364,
    % https://doi.org/10.1016/0022-2364(88)90131-X

    properties (GetAccess = public, SetAccess = public)
        type  mri_rf_pulse_sim.ui_prop.list
        maxB1 mri_rf_pulse_sim.ui_prop.scalar                              % [T]     max value of magnitude(t)
        maxGZ mri_rf_pulse_sim.ui_prop.scalar                              % [T/m]   max value of  gradient(t)
        maxSZ mri_rf_pulse_sim.ui_prop.scalar                              % [T/m/s] max(dGZ/dt)
    end % props

    methods(Access = public)

        function self = verse()
            self.type  = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='type' , value= 'rand' , items= {'<no>', 'optimise', 'rand'});
            self.maxB1 = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='maxB1', value= 15e-6, scale=1e6, unit='µT'     );
            self.maxGZ = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='maxGZ', value= 40e-3, scale=1e3, unit='mT/m'   );
            self.maxSZ = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='maxSZ', value=120   , scale=1  , unit='mT/m/ms');
        end % fcn

        function verse_modulation(self)

            % adjust time so it starts at 0
            if self.time(1) < 0
                self.time = self.time - self.time(1);
            end

            % shortcuts
            lim_b = self.maxB1.get();
            lim_g = self.maxGZ.get();
            lim_s = self.maxSZ.get();

            % same names as in the article
            N  = self.n_points.get();
            b = self.B1;
            g = self.GZ;
            dt = diff(self.time);

            DEBUG = true;
            
            if DEBUG
                self.type.value = 'optimise';
                figure(100)
                clf
            end
            
            switch self.type.get()

                case '<no>'
                    % useful to **not** do VERSE, to check basic pulse
                    % shape and behaviour

                case 'rand'
                    % this `rand` strategy is mostly for testing purpose,
                    % to show that the approach from the article works,
                    % whatever the content of a(k) modulation fuction !
                    a  = rand(size(b));
                    b  = a  .* self.B1;
                    g  = a  .* self.GZ;
                    dt = dt ./ a(1:N-1);

                case 'optimise'
                    % Hargreaves BA, Cunningham CH, Nishimura DG, Conolly
                    % SM. Variable-rate selective excitation for rapid MRI
                    % sequences. Magn Reson Med. 2004 Sep;52(3):590-7. doi:
                    % 10.1002/mrm.20168. PMID: 15334579.

                    % 1. The RF waveform is uniformly compressed in time
                    % until the maximum RF amplitude is reached.

                    step1_compression_factor = lim_b/max(abs(b));
                    b  = b  * step1_compression_factor;
                    g  = g  * step1_compression_factor;
                    dt = dt / step1_compression_factor;

                    % 2. The constant gradient waveform amplitude (g) for
                    % the initial RF pulse and given slab thickness is
                    % calculated.

                    % !!! dont need this !!!

                    % 3. Ignoring the gradient slew rate limit, the
                    % gradient waveform and RF are compressed together in
                    % time so that either the RF or the gradient are always
                    % at the maximum amplitude.

                    step2_compression_factor = zeros(size(b));
                    for k = 1 : N
                        b_factor = lim_b/abs(b(k));
                        g_factor = lim_g/abs(g(k));
                        step2_compression_factor(k) = min(b_factor,g_factor);
                    end
                    b  = b  .* step2_compression_factor;
                    g  = g  .* step2_compression_factor;
                    dt = dt ./ step2_compression_factor(1:N-1);

                    % 4. The end-points of the gradient and RF are set to
                    % zero.

                    b(1) = 0; b(N) = 0;
                    g(1) = 0; g(N) = 0;

                    % 5. At each point in the gradient where the slew rate
                    % is violated, the gradient and RF waveforms are
                    % expanded together in time to eliminate the slew-rate
                    % violation, while maintaining the same excitation
                    % k-space RF deposition. This step is applied
                    % recursively, as expanding one time point often
                    % results in a slew violation elsewhere in the
                    % waveform.
                    if DEBUG

                        self.time = [self.time(1) cumsum(dt)];
                        self.B1   = b;
                        self.GZ   = g;
                        self
                        clf
                        self.plot(gcf)

                        TOL = 1e-3;
                        CONDITION = true;
                        ITER = 0;
                        LIM = 0.99;
                        while CONDITION
                            
                            ITER = ITER + 1;

                            if mod(ITER,2) == 0
                                STATE = 'forward';
                            else
                                STATE = 'backward';
                            end
                            
                            switch STATE
                                case 'forward'
                                    VECT = 1   : +1 : N-1;
                                case 'backward'
                                    VECT = N-1 : -1 : 2;
                            end

                            for k = VECT

                                sr_k = (g(k+1)-g(k)) / dt(k);
                                s_break = abs(sr_k) > lim_s;

                                if s_break

                                    % We need to solve this equation to find the new a(k), which will respect the SlewRate :
                                    %
                                    % FOWARD :
                                    % lim_s = (g(k+1)*ak-g(k)) / dt(k)
                                    % preserving g(1)=0 forces us to change g(2)
                                    % This a first order polynome : Ax + B = 0
                                    %
                                    % BACKWARD :
                                    % lim_s = (g(k+1)-g(k)*ak) / (dt(k)/ak)
                                    % preserving g(N)=0 forces us to change g(N-1)
                                    % This a second order polynome : Ax² + Bx + C  = 0
                                    %
                                    
                                    sgn = sign(sr_k);
                                    
                                    switch STATE
                                        case 'forward'

                                            ak = [
                                                (g(k)+sgn*lim_s*dt(k))/g(k+1)
                                                LIM
                                                ];
                                            
                                            
                                            ak = max(ak(:)); % keep minimal decompression factor;

                                            b (k+1) =  b(k+1) * ak;
                                            g (k+1) =  g(k+1) * ak;
                                            if k < N-1
                                                dt(k+1) = dt(k+1) / ak;
                                            end

                                            % regularization
                                            b_factor = abs(b(k+1))/lim_b;
                                            g_factor = abs(g(k+1))/lim_g;
                                            if b_factor>1 || g_factor>1
                                                
%                                                                             self.time = [self.time(1) cumsum(dt)];
%                                                                             self.B1   = b;
%                                                                             self.GZ   = g;
%                                                                             clf
%                                                                             self.plot(gcf)
                                                                            
                                                ak = min(b_factor,g_factor);
                                                b (k+1) =  b(k+1) * ak;
                                                g (k+1) =  g(k+1) * ak;
                                                if k < N-1
                                                    dt(k+1) = dt(k+1) / ak;
                                                end
                                                
%                                                                             self.time = [self.time(1) cumsum(dt)];
%                                                                             self.B1   = b;
%                                                                             self.GZ   = g;
%                                                                             clf
%                                                                             self.plot(gcf)
                                            end

                                        case 'backward'


                                            A = -g(k);
                                            B = +g(k+1);
                                            C = -sgn*lim_s*(dt(k));

                                            DELTA = B^2 - 4*A*C;
                                            ak = [
                                                (-B +sqrt(DELTA))/(2*A)
                                                (-B -sqrt(DELTA))/(2*A)
                                                LIM
                                                ];
                                            
                                            
                                            ak = max(ak(:)); % keep minimal decompression factor;

                                            b (k) =  b(k) * ak;
                                            g (k) =  g(k) * ak;
                                            dt(k) = dt(k) / ak;                         

                                            % regularization
                                            idx_reg = k;
                                            b_factor = abs(b(idx_reg))/lim_b;
                                            g_factor = abs(g(idx_reg))/lim_g;
                                            if b_factor>1 || g_factor>1
                                                
%                                                                             self.time = [self.time(1) cumsum(dt)];
%                                                                             self.B1   = b;
%                                                                             self.GZ   = g;
%                                                                             clf
%                                                                             self.plot(gcf)
                                                
                                                ak = min(b_factor,g_factor);
                                                b (idx_reg) =  b(idx_reg) * ak;
                                                g (idx_reg) =  g(idx_reg) * ak;
                                                dt(idx_reg) = dt(idx_reg) / ak;
                                                
%                                                                             self.time = [self.time(1) cumsum(dt)];
%                                                                             self.B1   = b;
%                                                                             self.GZ   = g;
%                                                                             clf
%                                                                             self.plot(gcf)
                                            end
                                            
                                    end
                                    
%                                     fprintf('%03d %8s %f %03d \n', ITER, STATE, ak, k)
                                   

                                end

                            end % FOR::k


                            b(1) = 0; b(N) = 0;
                            g(1) = 0; g(N) = 0;

                            if mod(ITER,100) == 0 || mod(ITER,100) == 1
                                fprintf('%03d %8s %g \n', ITER, STATE, sum(dt)*1e3)

                                self.time = [self.time(1) cumsum(dt)];
                                self.B1   = b;
                                self.GZ   = g;
                                clf
                                self.plot(gcf)
                            end

                            s = diff(g) ./ dt;
                            CONDITION = abs(max(abs(s)) - lim_s) > TOL;

                        end % WHILE

                    end % DEBUG

                otherwise
                    error('verse type ?')

            end % switch

            t = [self.time(1) cumsum(dt)];

            self.time = t;
            self.B1   = b;
            self.GZ   = g;
            if DEBUG
                clf
                self.plot(gcf)
            end
        end % fcn

        function init_verse_gui(self, container)
            self.type.add_uicontrol(container, [0.00 0.00 0.40 1.00]);
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.maxB1 self.maxGZ self.maxSZ],...
                [0.40 0.00 0.60 1.00]);
        end % fcn

    end % meths

end % class
