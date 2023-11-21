classdef analysis < matlab.unittest.TestCase

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
            output = eval(to_eval);
            if ishandle(output)
                close(output)
            end
        end

    end

end % class
