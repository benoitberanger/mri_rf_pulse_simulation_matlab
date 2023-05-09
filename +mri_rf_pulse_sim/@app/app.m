classdef app < handle
    
    properties (GetAccess = public,  SetAccess = public)
        
        rf_pulse     mri_rf_pulse_sim.rf_pulse.base
        
    end % props
    
    properties (GetAccess = public,  SetAccess = protected)
        
        pulse_definition mri_rf_pulse_sim.pulse_definition
        simpar   struct
        simres   struct
        
    end % props
    
    methods (Access = public)
        
        % contructor
        function self = app(varargin)
            
            if ~nargin
                self.open_gui();
            end
            
        end % fcn
        
    end % meths
    
    methods (Access = protected)
        
        function open_gui(self)
            self.pulse_definition     = mri_rf_pulse_sim.pulse_definition('open_gui');
            self.pulse_definition.app = self;
        end % fcn
        
    end % meths
    
end % class
