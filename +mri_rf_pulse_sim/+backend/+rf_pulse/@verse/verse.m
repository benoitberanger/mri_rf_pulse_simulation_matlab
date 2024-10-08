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
            self.type  = mri_rf_pulse_sim.ui_prop.list  (parent=self, name=''     , value= 'optimise' , items= {'<no>', 'optimise', 'rand'});
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
            b  = self.B1;
            g  = self.GZ;
            dt = diff(self.time);
            t  = [self.time(1) cumsum(dt)];

            switch self.type.get()

                case '<no>'
                    % useful to **not** do VERSE, to check basic pulse
                    % shape and behaviour

                case 'rand'
                    % this `rand` strategy is mostly for testing purpose,
                    % to show that the approach from the article works,
                    % whatever the content of a(k) modulation function !
                    a  = rand(size(b));
                    b  = a  .* b;
                    g  = a  .* g;
                    dt = dt ./ a(1:N-1);
                    t  = [self.time(1) cumsum(dt)];

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

                    ALPHA_MAX = 1.01;
                    TOLERANCE = 1e-3;
                    ITER = 0;
                    CONDITION = true;

                    while CONDITION

                        ITER = ITER + 1;

                        %----------------------------------------------
                        % Backward

                        % This force artificial high slew rate to regularise the ramp up
                        b(N)  = 0;
                        g(N)  = 0;

                        for k = N:-1:2

                            sk = (g(k)-g(k-1))/dt(k-1);

                            if abs(sk) > lim_s
                                % slew rate limte broken : decompress waveforms
                                A       = dt(k-1) * lim_s * sign(sk);
                                B       = - g(k);
                                C       = g(k-1);
                                delta   = B^2 - 4*A*C;
                                sqDelta = sqrt(delta);
                                x1      = (-B-sqDelta)/A*0.5;
                                x2      = (-B+sqDelta)/A*0.5;
                                x       = [x1 x2];
                                x       = x(x>0);
                                alpha   = min(x);
                                % just decompress by a small value
                                % this is the "iterative approach"
                                alpha   = min(alpha,ALPHA_MAX);
                                g (k-1) = g (k-1) / alpha;
                                b (k-1) = b (k-1) / alpha;
                                dt(k-1) = dt(k-1) * alpha;
                            end

                            % after decompression, we might have broken B1max and GZmax
                            % so need to regulirize
                            if abs(b(k-1)) > lim_b
                                alpha   = abs(b(k-1)) / lim_b;
                                g (k-1) = g (k-1) / alpha;
                                b (k-1) = b (k-1) / alpha;
                                dt(k-1) = dt(k-1) * alpha;
                            end
                            if abs(g(k-1)) > lim_g
                                alpha   = abs(g(k-1)) / lim_g;
                                g (k-1) = g (k-1) / alpha;
                                b (k-1) = b (k-1) / alpha;
                                dt(k-1) = dt(k-1) * alpha;
                            end

                        end % k

                        %----------------------------------------------
                        % Forward

                        g(1)  = 0;

                        for k = 1:N-1

                            sk = (g(k+1)-g(k))/dt(k);

                            if abs(sk) > lim_s
                                alpha  = g(k+1) / (sign(sk)*lim_s*dt(k)+g(k));
                                if alpha == 0 && g(k+1) == 0 % edge case
                                    alpha = eps;
                                end
                                alpha  = min(alpha,ALPHA_MAX);
                                g(k+1) = g(k+1) / alpha;
                                b(k+1) = b(k+1) / alpha;
                                if k < N-1
                                    dt(k+1) = dt(k+1) * alpha;
                                end
                            end

                        end % k

                        %----------------------------------------------
                        % Check SlewRate
                        s = diff(g) ./ dt;
                        CONDITION = abs(max(abs(s)) - lim_s) > TOLERANCE;

                    end % WHILE

                    t = [self.time(1) cumsum(dt)];
                    %                     % resample time so it is linearly spaced
                    %                     tv = [self.time(1) cumsum(dt)];
                    %                     T0 = tv(1);
                    %                     Tp = tv(N);
                    %                     t  = linspace(T0,Tp,N);
                    %                     b  = interp1(tv, b, t, 'linear');
                    %                     g  = interp1(tv, g, t, 'linear');

                otherwise
                    error('verse type ?')

            end % switch

            self.time = t;
            self.B1   = b;
            self.GZ   = g;

        end % fcn

        function init_verse_gui(self, container)
            self.type.add_uicontrol(container, [0.00 0.00 0.40 1.00]);
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.maxB1 self.maxGZ self.maxSZ],...
                [0.40 0.00 0.60 1.00]);
        end % fcn

        % Nicer GZ rewinder using the constrains
        function add_gz_rewinder_verse(self, status)
            self.gz_rewinder.visible = "on";
            if nargin == 1, status = self.gz_rewinder.get(); end
            if ~status    , return                         , end

            target_moment = trapz(self.time,self.GZ) / 2;
            dt = mean(diff(self.time));

            half_g = 0;
            half_t = 0;
            current_moment = 0;

            while current_moment <= target_moment
                next = half_g(end) + self.maxSZ*dt;

                if next <= self.maxGZ.get()
                    half_g(end+1) = next;
                elseif next > self.maxGZ.get()
                    half_g(end+1) = self.maxGZ.get();
                end

                half_t(end+1) = half_t(end)+dt;
                current_moment = 2 * trapz(half_t,half_g);
            end

            self.time = [self.time self.time(end)+half_t];
            self.time = [self.time self.time(end)+half_t];
            self.B1   = [self.B1   zeros(1,length(half_t)*2)];
            self.GZ   = [self.GZ   -half_g -fliplr(half_g)];
        end % fcn

    end % meths

end % class
