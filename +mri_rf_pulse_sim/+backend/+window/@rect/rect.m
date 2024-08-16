classdef rect < mri_rf_pulse_sim.backend.window.abstract

    methods (Access = public)

        % constructor
        function self = rect(args)
            arguments
                args.rf_pulse
            end % args

            % default parameters
            self.name = mfilename;

            if length(fieldnames(args)) < 1, return, end

            if isfield(args, 'rf_pulse'), self.rf_pulse = args.rf_pulse; end
        end % fcn

        function shape = getShape(self, time)
            shape = ones(size(time));
            self.time  = time;
            self.shape = shape;
        end % fcn

        function init_gui(~, ~)
        end % fcn

        % synthesis text
        function txt = summary(~)
            txt = 'rect window';
        end % fcn

    end % meths

end % class
