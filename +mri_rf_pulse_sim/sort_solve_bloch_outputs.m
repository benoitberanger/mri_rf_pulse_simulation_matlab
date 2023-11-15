function output = sort_solve_bloch_outputs(args)
% REQUIRED arguments
%   M      (double) : ouput of `solve_bloch`
%   select (char  ) : 'slice_profile', 'slice_middle'
%
% !!! this function is a work-in-progress !!!

arguments
    args.M
    args.select
end

assert(isfield(args, 'M'     ), help(mfilename('fullpath')))
assert(isfield(args, 'select'), help(mfilename('fullpath')))
assert(ischar(args.select)    , help(mfilename('fullpath')))

if strcmp(args.select, 'slice_profile')
    output = squeeze(args.M(3,end,:));
end

if strcmp(args.select, 'slice_middle')
    output = args.M(3,end,round(end/2));
end

end % fcn
