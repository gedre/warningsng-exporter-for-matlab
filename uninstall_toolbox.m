function uninstall_toolbox()
    % Uninstall the MATLAB toolbox. This is for testing only.

    load('toolbox_struct.mat', 'toolbox_struct'); % get toolbox data from the installation step

    matlab.addons.toolbox.uninstallToolbox(toolbox_struct); % uninstall the toolbox
    disp("Uninstalled the toolbox");

    % print installed addons to the screen to verify the removal of the WarningsNG Exporter toolbox
    matlab.addons.installedAddons()
end
