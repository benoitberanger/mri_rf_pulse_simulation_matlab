function varargout = run_all_UT()

ut_path = fileparts(mfilename('fullpath'));
results = runtests(ut_path);

if nargout
    varargout{1} = results;
else
    disp(table(results))
end

end % fcn
