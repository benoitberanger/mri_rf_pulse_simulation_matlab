classdef hamming < mri_rf_pulse_sim.window.hanning

    methods (Access = public)


        function self = hamming(args)
            arguments
                args.rf_pulse
            end % args

            % default paramters
            self@mri_rf_pulse_sim.window.hanning()
            self.name = mfilename;
            self.a0.set(0.53836)
            self.a1.set(0.46164)

            if length(fieldnames(args)) < 1
                return
            end

            if isfield(args, 'rf_pulse'), self.rf_pulse = args.rf_pulse; end
        end % fcn

    end % meths

end % class
