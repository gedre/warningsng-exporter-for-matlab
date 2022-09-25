function uninstall_toolbox()
    % Uninstall the MATLAB toolbox.
    % This is for testing only.

    load('toolbox_struct.mat', 'toolbox_struct');

    % uninstall the toolbox
    matlab.addons.toolbox.uninstallToolbox(toolbox_struct);
    disp("Uninstalled the toolbox");

    % verify the installation
    matlab.addons.installedAddons()
end
