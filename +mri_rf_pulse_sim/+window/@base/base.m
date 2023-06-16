classdef base < mri_rf_pulse_sim.base_class

    properties (GetAccess = public, SetAccess = public)
        name     (1,:) char
        rf_pulse       mri_rf_pulse_sim.rf_pulse.base                      % pointer to the container
    end % props

end % class
