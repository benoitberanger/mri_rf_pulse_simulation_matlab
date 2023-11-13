function results = run_all_UT()
ut_path = fileparts(mfilename('fullpath'));
results = runtests(ut_path);
end % fcn
