function pulse_list = get_list()
% fetch the list pulses in the library

% SINC is the "default" pulse, use it's location as starting point
base_path = which(class(mri_rf_pulse_sim.rf_pulse.sinc));
package_path = fileparts(fileparts(base_path));

% fetch all classes in the package_path : they are pulses
dir_root = dir(fullfile(package_path, '@*'));
pulse_list_root = {dir_root.name};
pulse_list_root = strrep(pulse_list_root, '@', '');

% and fetch all sub-package classes : they are pulses
pulse_list_sub = cell(0);
dir_sub = dir(fullfile(package_path, '+*'));
for  i = 1 : length(dir_sub)
    dir_sub_current = dir(fullfile(dir_sub(i).folder, dir_sub(i).name, '@*'));
    pulse_list_sub_current = {dir_sub_current.name};
    pulse_list_sub_current = strrep(pulse_list_sub_current, '@', '');
    pulse_list_sub = [pulse_list_sub strcat(dir_sub(i).name(2:end),filesep,pulse_list_sub_current)]; %#ok<AGROW>
end

% User defined pulses : they are in +mri_rf_pulse_sim/+rf_pulse/+local
% This wat, the GUI will behave just the same !

% concatenate all
pulse_list = [pulse_list_root pulse_list_sub]';

end % fcn
