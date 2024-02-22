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
            self.type  = mri_rf_pulse_sim.ui_prop.list  (parent=self, name='type' , value= 'rand' , items= {'<no>', 'min_time', 'low_SAR', 'rand'});
            self.maxB1 = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='maxB1', value= 15e-6, scale=1e6, unit='µT'     );
            self.maxGZ = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='maxGZ', value= 40e-3, scale=1e3, unit='mT/m'   );
            self.maxSZ = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='maxSZ', value=120e-3, scale=1e3, unit='mT/m/ms');
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
            dt = diff(self.time);
            N  = self.n_points.get();
            %             k  = 1 : N;
            ak = ones(1,N);
            %             tk = dt ./ ak(1:N-1);
            bk = ak .* self.B1;
            G  = self.GZavg;
            gk = ak  * G;

            switch self.type.get()

                case '<no>'
                    % useful to **not** do VERSE, to check basic pulse
                    % shape and behaviour

                case 'rand'
                    % this `rand` strategy is mostly for testing purpose,
                    % to show that the approach from the article works,
                    % whatever the content of a(k) modulation fuction !
                    ak = rand(size(ak));
                    bk = ak .* self.B1;
                    gk = ak  * G;

                case 'min_time'
                    % Hargreaves BA, Cunningham CH, Nishimura DG, Conolly
                    % SM. Variable-rate selective excitation for rapid MRI
                    % sequences. Magn Reson Med. 2004 Sep;52(3):590-7. doi:
                    % 10.1002/mrm.20168. PMID: 15334579.

                    % 1. The RF waveform is uniformly compressed in time
                    % until the maximum RF amplitude is reached.

                    step1_compression_factor = lim_b/max(abs(bk));
                    ak = ak  * step1_compression_factor;
                    bk = ak .* self.B1;
                    gk = ak  * G;

                    % 2. The constant gradient waveform amplitude (g) for
                    % the initial RF pulse and given slab thickness is
                    % calculated.

                    % G  = G * step1_compression_factor; % !!! dont need this update !!!

                    % 3. Ignoring the gradient slew rate limit, the
                    % gradient waveform and RF are compressed together in
                    % time so that either the RF or the gradient are always
                    % at the maximum amplitude.

                    for k = 1 : N
                        b_factor = lim_b/abs(bk(k));
                        g_factor = lim_g/abs(gk(k));
                        ak(k) = ak(k) * min(b_factor,g_factor);
                    end
                    bk = ak .* self.B1;
                    gk = ak  * G;

                case 'low_SAR'
                    % TODO

                otherwise
                    error('verse type ?')

            end

            self.time = [self.time(1) cumsum(dt ./ ak(1:N-1))];
            self.B1   = bk;
            self.GZ   = gk;

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
