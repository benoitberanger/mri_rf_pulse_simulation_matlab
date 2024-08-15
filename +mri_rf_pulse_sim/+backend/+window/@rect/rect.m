classdef rect < mri_rf_pulse_sim.backend.window.abstract

    properties (GetAccess = public, SetAccess = public, Dependent)
        shape
    end % props

    methods % no attribute for dependent properties
        
        function value = get.shape(self)
            if isempty(self.time)
                time = self.rf_pulse.time;
            else
                time = self.time;
            end

            value = ones(size(time));
        end % fcn
        
    end % meths

    methods (Access = public)

        % constructor
        function self = rect(args)
            arguments
                args.rf_pulse
            end % args

            % default parameters
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
