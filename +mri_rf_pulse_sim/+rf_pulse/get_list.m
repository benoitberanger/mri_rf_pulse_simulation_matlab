function pulse_list = get_list()

base_path = which(class(mri_rf_pulse_sim.rf_pulse.base));
package_path = fileparts(fileparts(base_path));

dir_root = dir(fullfile(package_path, '@*'));
pulse_list_root = {dir_root.name};
pulse_list_root = strrep(pulse_list_root, '@', '');
pulse_list_root(strcmp(pulse_list_root,'base')) = []; % remove base rf pulse class

pulse_list_sub = cell(0);
dir_sub = dir(fullfile(package_path, '+*'));
for  i = 1 : length(dir_sub)
    dir_sub_current = dir(fullfile(dir_sub(i).folder, dir_sub(i).name, '@*'));
    pulse_list_sub_current = {dir_sub_current.name};
    pulse_list_sub_current = strrep(pulse_list_sub_current, '@', '');
    pulse_list_sub = [pulse_list_sub pulse_list_sub_current]; %#ok<AGROW> 
end

pulse_list = [pulse_list_root pulse_list_sub];

end % fcn
