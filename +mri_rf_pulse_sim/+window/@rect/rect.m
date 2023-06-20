classdef rect < mri_rf_pulse_sim.window.base

    properties (GetAccess = public, SetAccess = public)
        shape (1,:) double                                                 % shape of the window
    end % props

    methods % no attribute for dependent properies
        function value = get.shape(self)
            value = ones(size(self.rf_pulse.time));
        end % fcn
    end % meths

    methods (Access = public)

        % constructor
        function self = rect(args)
            arguments
                args.rf_pulse
            end % args

            % default paramters
            self.name = mfilename;

            if length(fieldnames(args)) < 1
                return
            end

            if isfield(args, 'rf_pulse'), self.rf_pulse = args.rf_pulse; end
        end % fcn

        function init_gui(~, ~)
        end % fcn

        % synthesis text
        function txt = summary(~)
            txt = 'rect window';
        end % fcn

    end % meths

end % class
