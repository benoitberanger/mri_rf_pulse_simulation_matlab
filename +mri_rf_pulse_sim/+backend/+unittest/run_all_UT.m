function varargout = run_all_UT()
% Run all UnitTests.
% All UT are in one dir, containing all class dereived from matlab.unittest.TestCase

t0 = tic;
ut_path = fileparts(mfilename('fullpath'));
results = runtests(ut_path);

if nargout
    varargout{1} = results;
else
    disp(table(results))
    fprintf('[%s]: all tests done in %gs \n', mfilename, toc(t0));
end

end % fcn
