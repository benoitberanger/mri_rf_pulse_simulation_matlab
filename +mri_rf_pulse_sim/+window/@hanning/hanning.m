classdef hanning < mri_rf_pulse_sim.window.base

    properties (GetAccess = public, SetAccess = public)
        shape (1,:) double                                                 % shape of the window

        a0    (1,1) double = +0.5
        a1    (1,1) double = +0.5
    end % props

    methods % no attribute for dependent properies
        function value = get.shape(self)
            value = self.a0 + self.a1 * cos(2*pi*self.rf_pulse.time/self.rf_pulse.duration);
        end % fcn
    end % meths

    methods (Access = public)

        % constructor
        function self = hanning(args)
            arguments
                args.rf_pulse
                args.a0
                args.a1
            end % args

            self.name = mfilename;

            if length(fieldnames(args)) < 1
                return
            end

            if isfield(args, 'rf_pulse'), self.rf_pulse = args.rf_pulse; end
            if isfield(args, 'a0'      ), self.a0       = args.a0      ; end
            if isfield(args, 'a1'      ), self.a1       = args.a1      ; end
        end % fcn

    end % meths

end % class
