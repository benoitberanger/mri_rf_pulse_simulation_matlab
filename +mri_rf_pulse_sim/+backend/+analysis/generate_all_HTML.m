function generate_all_HTML()

% get all anaysis scripts
% path_string = fullfile(mri_rf_pulse_sim.get_package_dir(), "+analysis", "*.m");
path_string = fullfile(mri_rf_pulse_sim.get_package_dir(), "+analysis", "rect_vs_sinc.m");
content = dir(path_string);
to_execute = {content.name};
to_execute = strrep(to_execute, '.m', '');
N = length(to_execute);

% options for the `publish` function
options           = struct;
options.outputDir = fullfile(fileparts(mri_rf_pulse_sim.get_package_dir()), 'html_publish_matlab');
options.format    = 'html';

% publish
t0 = tic;
for idx = 1 : N
    file = sprintf('mri_rf_pulse_sim.analysis.%s', to_execute{idx});
    fprintf('[%s] %d/%d : %s \n', mfilename, idx, N, file);
    publish(file,options);
    close all
    web(fullfile(options.outputDir, [to_execute{idx} '.html']), '-new')
end
fprintf('[%s] done  in %gs \n', mfilename, toc(t0));

end % fcn
