classdef rf_pulse < matlab.unittest.TestCase


    %% general parameters

    properties
        fig
    end


    %% Executed once BEFORE all Methods

    methods(TestClassSetup)

        function verify_get_list_function_exists(testCase)
            testCase.verifyNotEmpty(which('mri_rf_pulse_sim.backend.rf_pulse.get_list'))
        end

        function open_fig_for_pulse_plot(testCase)
            testCase.fig = figure('NumberTitle','off');
            testCase.addTeardown(@close, testCase.fig)
        end

    end


    %% Executed between ClassSetup and Methods

    properties(TestParameter)
        pulse
    end

    methods(TestParameterDefinition, Static)

        function pulse = get_pulse_list()
            pulse = mri_rf_pulse_sim.backend.rf_pulse.get_list();
        end

    end


    %% Execute for each TestParameter

    methods(Test)

        function check(testCase, pulse)

            % instantiate
            if any(pulse == filesep)
                split = strsplit(pulse, filesep);
                pulse_relpath = sprintf('mri_rf_pulse_sim.rf_pulse.%s.%s', split{1}, split{2});
            else
                pulse_relpath = sprintf('mri_rf_pulse_sim.rf_pulse.%s', pulse);
            end
            p = eval(pulse_relpath);

            % plot
            clf(testCase.fig)
            p.plot(testCase.fig)
            testCase.fig.Name = p.summary();

        end

    end

end % class
