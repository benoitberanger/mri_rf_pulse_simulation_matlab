classdef slr < mri_rf_pulse_sim.backend.rf_pulse.abstract
    % Shinnar-Le Roux

    properties (GetAccess = public, SetAccess = public)
        d1          mri_rf_pulse_sim.ui_prop.scalar                        % [] ripple ratio on the rect top      (from 0 to 1)
        d2          mri_rf_pulse_sim.ui_prop.scalar                        % [] ripple ratio on the rect baseline (from 0 to 1)
        TBWP        mri_rf_pulse_sim.ui_prop.scalar                        % [] TimeBandWidthProduct
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
            self.d1       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='d1'      , value=  0.01, unit='from 0 to 1');
            self.d2       = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='d2'      , value=  0.01, unit='from 0 to 1');
            self.TBWP     = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='TBWP'    , value=  4                       );
            self.pulse_type  = 'ex';
            self.filter_type = 'pm';
            self.generate_slr();
        end % fcn

        function generate(self)
            self.generate_slr();
        end % fcn

        % generate time, AM, FM, GM
        function generate_slr(self)

            [d1e, d2e] = self.effective_ripples(self.d1.get(), self.d2.get(), self.pulse_type);
            D = self.DinfLP(d1e, d2e);
            fractional_transition = D / self.TBWP;
            transition_band = self.bandwidth  * fractional_transition;
            normalized_transition_band = transition_band / self.bandwidth/2;
            fbot = 0.5 - normalized_transition_band/2;
            ftop = 0.5 + normalized_transition_band/2;

            freq_vector = [0 fbot ftop 1];
            mag_vector  = [1 1 0 0];
            ripple_vector = [d1e d2e];
            b = firpm(self.n_points.get(),freq_vector, mag_vector, ripple_vector);
            zerophase(b,1)

        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('slr : ??=%s',...
                ' ');
        end % fcn

        function init_specific_gui(self, container)
            %             mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
            %                 container,...
            %                 []...
            %                 );
        end % fcn

    end % meths

    methods (Access = private)



    end % meths

    methods(Static)

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

    end

end % class
