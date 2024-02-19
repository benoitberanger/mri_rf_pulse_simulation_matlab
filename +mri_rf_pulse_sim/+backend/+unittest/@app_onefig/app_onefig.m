classdef app_onefig < mri_rf_pulse_sim.backend.unittest.app

    methods(TestClassSetup)

        function open_app(testCase)
            testCase.verifyNotEmpty(testCase.app_path)
            testCase.application = feval(testCase.app_path,'opengui_onefig');
            testCase.addTeardown(@close, testCase.application.fig)
        end

    end % meths

end % class
