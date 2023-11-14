classdef app < matlab.unittest.TestCase

    properties
        obj_path (1,:) char = 'mri_rf_pulse_sim.app'
        obj
    end % props

    methods(TestClassSetup)
        
        % open the app once at the begining of the test(and prepare it's closing)
        function open_app(testCase)
            testCase.verifyNotEmpty(testCase.obj_path)
            testCase.obj = eval(testCase.obj_path);
            testCase.addTeardown(@close, testCase.obj.pulse_definition.fig)
        end
        
    end % meths

    methods(Test)

        % simple check
        function check_app_opened(testCase)
            testCase.verifyNotEmpty(testCase.obj)
        end

        % rf pulse
        function check_getPulse(testCase)
            testCase.verifyNotEmpty(testCase.obj.getPulse())
        end
        function check_setPulse(testCase)
            testCase.verifyNotEmpty(testCase.obj.setPulse('hs'))
        end
        
    end % meths

end % class
