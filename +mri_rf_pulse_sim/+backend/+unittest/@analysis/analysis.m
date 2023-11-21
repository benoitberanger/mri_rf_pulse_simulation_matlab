classdef analysis < matlab.unittest.TestCase

    methods(TestClassSetup)
        function prep_close(testCase)
            testCase.addTeardown(@close, 'all')
        end
    end

    properties(TestParameter)
        to_execute
    end

    methods (TestParameterDefinition, Static)
        function to_execute = initialize_script_list()
            path_string = fullfile(mri_rf_pulse_sim.get_package_dir(), "+analysis", "*.m");
            content = dir(path_string);
            to_execute = {content.name};
            to_execute = strrep(to_execute, '.m', '');
        end
    end

    methods(Test)
        function runner(testCase, to_execute)
            to_eval = sprintf('mri_rf_pulse_sim.analysis.%s', to_execute);
            eval(to_eval);
        end
    end

end % class
