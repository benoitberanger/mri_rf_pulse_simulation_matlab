function pulse_list = get_list()

base_path = which(class(mri_rf_pulse_sim.window.base));
package_path = fileparts(fileparts(base_path));
d = dir(fullfile(package_path, '@*'));
pulse_list = {d.name};
pulse_list = strrep(pulse_list, '@', '');
pulse_list(strcmp(pulse_list,'base')) = [];

end % fcn