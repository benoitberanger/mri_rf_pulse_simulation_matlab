classdef sinc_clipped < mri_rf_pulse_sim.rf_pulse.sinc
    % This pulse shows effect of RF clipping : or the pulse clips, or you
    % choose to adjust its flip angleto the maximum available "voltage"

    properties (GetAccess = public, SetAccess = public)
        max_B1  mri_rf_pulse_sim.ui_prop.scalar                            % [T] maximum B1 field, corresponds to a maxium Transmiter Voltage
        rescale mri_rf_pulse_sim.ui_prop.bool                              % [] adjust B1peak to max_B1 paramter
    end % props

    methods (Access = public)

        % constructor
        function self = sinc_clipped()
            self.max_B1  = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='max_B1' , value=10e-6, scale=1e6 , unit='µT');
            self.rescale = mri_rf_pulse_sim.ui_prop.bool  (parent=self, name='rescale', value=false, text='rescale');
            self.n_points.set(256);
            self.n_side_lobs.set(10);
            self.generate_sinc_clipped();
        end % fcn

        function generate(self) % #abstract
            self.generate_sinc_clipped();
            self.add_gz_rewinder();
        end % fcn

        function generate_sinc_clipped(self)
            self.generate_sinc();
            RE = self.real();
            IM = self.imag();
            if self.rescale.get()
                is_RE_clipping = any(abs(RE)/self.max_B1 > 1);
                is_IM_clipping = any(abs(IM)/self.max_B1 > 1);
                if is_RE_clipping || is_IM_clipping
                    factor = max( max(abs(RE)/self.max_B1) , max(abs(IM)/self.max_B1) );
                    RE = RE / factor;
                    IM = IM / factor;
                end
            else
                RE(RE>+self.max_B1.get()) = +self.max_B1.get();
                IM(IM>+self.max_B1.get()) = +self.max_B1.get();
                RE(RE<-self.max_B1.get()) = -self.max_B1.get();
                IM(IM<-self.max_B1.get()) = -self.max_B1.get();
            end
            self.B1 = RE + 1j*IM;
        end % fcn

        function init_specific_gui(self, container) % #abstract
            pos_sinc = [0.00 0.20 1.00 0.80];
            pos_new  = [0.00 0.00 1.00 0.20];

            panel_sinc = uipanel(Parent=container, Units="normalized", Position=pos_sinc, BackgroundColor=container.BackgroundColor);
            panel_new  = uipanel(Parent=container, Units="normalized", Position=pos_new , BackgroundColor=container.BackgroundColor);

            init_specific_gui@mri_rf_pulse_sim.rf_pulse.sinc(self,panel_sinc);
            self.max_B1 .add_uicontrol(panel_new,[0.00 0.00 0.60 1.00]);
            self.rescale.add_uicontrol(panel_new,[0.60 0.00 0.40 1.00]);
        end % fcn

    end % meths

end % class

function y = Sinc(x)
i    = find(x==0);        % identify the zeros
x(i) = 1;                 % fix the DIVIDED_BY_ZERO problem
y    = sin(pi*x)./(pi*x); % generate the Sinc curve
y(i) = 1;                 % fix the DIVIDED_BY_ZERO problem
end % fcn
