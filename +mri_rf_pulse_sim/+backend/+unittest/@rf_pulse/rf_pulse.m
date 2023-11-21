classdef rf_pulse < matlab.unittest.TestCase

    methods(TestClassSetup)

        function verify_get_list_function_exists(testCase)
            testCase.verifyNotEmpty(which('mri_rf_pulse_sim.backend.rf_pulse.get_list'))
        end

    end

    properties(TestParameter)
        pulse
    end

    methods(TestParameterDefinition, Static)

        function pulse = get_pulse_list()
            pulse = mri_rf_pulse_sim.backend.rf_pulse.get_list();
        end

    end

    methods(Test)

        function check(testCase, pulse)

            if any(pulse == filesep)
                split = strsplit(pulse, filesep);
                testCase.verifyNotEmpty( eval(sprintf('mri_rf_pulse_sim.rf_pulse.%s.%s', split{1}, split{2})) );
            else
                testCase.verifyNotEmpty( eval(sprintf('mri_rf_pulse_sim.rf_pulse.%s', pulse)) );
            end

        end

    end

end % class
