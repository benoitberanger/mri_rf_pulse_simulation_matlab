classdef slr_filter_type
    enumeration
        pm   % Parks-McClellan equal-ripple
        min  % minphase using factored pm
        max  % maxphase using factored pm
        ls   % least squares
    end
end
