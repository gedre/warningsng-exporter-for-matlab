function install_toolbox()
    % Install the MATLAB toolbox from the distribution package.
    % This is for testing only.

    % Docs on Toolbox Distribution:
    % web(fullfile(docroot, 'matlab/creating-help.html?s_tid=CRUX_lftnav'))

    cfdir = fileparts( mfilename('fullpath') ); % Get script directory
    toolbox_file_struct = dir(fullfile(cfdir, "*.mltbx")); % determine the prj file name, returns a struct
    toolbox_file_full = fullfile(toolbox_file_struct(1).folder, toolbox_file_struct(1).name);
    disp("Using toolbox file " + toolbox_file_full);

    % install the toolbox
    toolbox_struct = matlab.addons.toolbox.installToolbox(toolbox_file_full);
    save('toolbox_struct.mat', 'toolbox_struct');
    disp("Installed the toolbox");

    % verify the installation
    matlab.addons.installedAddons()
end
