classdef hanning < mri_rf_pulse_sim.backend.window.abstract

    properties (GetAccess = public, SetAccess = public)
        a0    mri_rf_pulse_sim.ui_prop.scalar
        a1    mri_rf_pulse_sim.ui_prop.scalar
    end % props

    methods (Access = public)

        % constructor
        function self = hanning(args)
            arguments
                args.rf_pulse
                args.a0
                args.a1
            end % args

            % default parameters
            self.name = mfilename;
            self.a0 = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='a0', value=+0.5);
            self.a1 = mri_rf_pulse_sim.ui_prop.scalar(parent=self, name='a1', value=+0.5);

            if length(fieldnames(args)) < 1, return, end

            if isfield(args, 'rf_pulse'), self.rf_pulse = args.rf_pulse; end
            if isfield(args, 'a0'      ), self.a0.set(args.a0)         ; end
            if isfield(args, 'a1'      ), self.a1.set(args.a1)         ; end
        end % fcn

        function shape = getShape(self, time)
            % adjust time so it is symmetrical
            if time(1) == 0
                t = time - time(end)/2; % useful for VERSE
            else
                t = time;
            end

            d = t(end)-t(1);
            shape = self.a0 + self.a1 * cos(2*pi*t/d);

            self.time  = time;
            self.shape = shape;
        end % fcn

        function init_gui(self, container)
            mri_rf_pulse_sim.ui_prop.scalar.add_uicontrol_multi_scalar(...
                container,...
                [self.a0, self.a1]...
                );
        end % fcn

        % synthesis text
        function txt = summary(self)
            txt = sprintf('%s window : a0=%s  a1=%s',...
                self.name, self.a0.repr, self.a1.repr);
        end % fcn

    end % meths

end % class
