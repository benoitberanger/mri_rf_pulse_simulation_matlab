classdef app < matlab.unittest.TestCase


    %% general paramters

    properties
        app_path    (1,:) char = 'mri_rf_pulse_sim.app'                    % i need to define the *matlab* path of the app
        application                                                        % this will receive the pointer to the app
    end


    %% Executed once per ClassSetupParameter, then all Methods are executed for EACH ClassSetupParameter

    properties (ClassSetupParameter)
        opening_args = {'opengui', 'opengui_onefig'};
    end

    methods(TestClassSetup)

        % open the app at the begining of the test (and prepare it's closing)
        function open_app(testCase, opening_args)
            testCase.verifyNotEmpty(testCase.app_path)
            testCase.application = feval(testCase.app_path, opening_args);
            testCase.addTeardown(@close, testCase.application.pulse_definition.fig)
        end

    end


    %% Executed each time after Method execution

    methods(TestMethodTeardown)

        % at the end of each test, wait for all figures to be fully updated
        function update_gui(testCase) %#ok<MANU>
            drawnow();
        end

    end % meths


    %% Execute sequencially each Method once per ClassSetupParameter (see above)

    methods(Test)

        % simple check
        function check_app_opened(testCase)
            testCase.verifyNotEmpty(testCase.application)
        end

        % rf pulse
        function getPulse(testCase)
            testCase.verifyNotEmpty(testCase.application.getPulse())
        end
        function setPulse(testCase)
            target_pulse = 'foci'; % FOCI is derived from HS, it's a nice crash test
            testCase.verifyNotEmpty(testCase.application.setPulse(target_pulse))
            handles = guidata(testCase.application.pulse_definition.fig); % now check if listbox is correclty updated
            testCase.verifyEqual(handles.listbox_rf_pulse.String{handles.listbox_rf_pulse.Value}, target_pulse)
        end
        function set_duration(testCase)
            testCase.application.getPulse().duration.set(0.005)
        end

        % dZ / dB0
        function set_N_dB0(testCase)
            testCase.application.simulation_parameters.dB0.N = 11;
        end
        function set_display_dZ_last(testCase)
            testCase.application.simulation_parameters.dZ.select = testCase.application.simulation_parameters.dZ.vect(end);
        end
        function set_display_dZ_middle(testCase)
            testCase.application.simulation_parameters.dZ.select = testCase.application.simulation_parameters.dZ.middle_value;
        end

        % B0
        function set_B0(testCase)
            testCase.application.simulation_parameters.B0.set(3);
        end

        % M0
        function set_M0_xyz(testCase)
            testCase.application.simulation_parameters.M0.xyz = [0.0 0.1 0.9];
        end
        function set_M0_z(testCase)
            testCase.application.simulation_parameters.M0.z = 0.8;
        end

        % T1 & T2 relaxation
        function set_T1(testCase)
            testCase.application.simulation_parameters.T1.set(0.100);
        end
        function set_T2(testCase)
            testCase.application.simulation_parameters.T2.set(0.010);
        end

    end % meths


end % class
