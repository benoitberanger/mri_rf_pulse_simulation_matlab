classdef rf_pulse < matlab.unittest.TestCase

    properties
        get_list_function (1,:) char = 'mri_rf_pulse_sim.backend.rf_pulse.get_list'
        pulse_list        (:,1) cell
    end % props

    properties (TestParameter)

    end % props

    methods(TestClassSetup)

        function assign_pulse_list(testCase)
            testCase.verifyNotEmpty(testCase.get_list_function)
            testCase.pulse_list = eval(testCase.get_list_function);
        end

    end

    methods(Test)

        function list_pulse_exists(testCase)
            assert(~isempty(which(testCase.get_list_function)),'get_list function not found')
        end

        function non_empty_list_pulse(testCase)
            assert(~isempty(testCase.pulse_list), 'empty pulse list using')
        end

        function list_pulse_has_sinc(testCase)
            assert(any(contains(testCase.pulse_list,'sinc')), 'sinc pulse not found')
        end

        function check_all_pulses(testCase)
            for p = 1 : length(testCase.pulse_list)

                pulse = testCase.pulse_list{p};

                if any(pulse == filesep)
                    split = strsplit(pulse, filesep);
                    testCase.verifyNotEmpty( eval(sprintf('mri_rf_pulse_sim.rf_pulse.%s.%s', split{1}, split{2})) );
                else
                    testCase.verifyNotEmpty( eval(sprintf('mri_rf_pulse_sim.rf_pulse.%s', pulse)) );
                end

            end
        end

    end % meths

end % class
