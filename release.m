function release()
    % RELEASE Create the release and pack a MATLAB toolbox.
    % The release version is updated in the 'Contents.m' file.

    % Get release script directory
    cfdir = fileparts( mfilename('fullpath') );
    % determine the prj file name
    prjfile_dir = dir(fullfile(cfdir, "*.prj"));
    prjfile = fullfile(prjfile_dir(1).folder, prjfile_dir(1).name);
    % extract project base name form project file name
    [~, prjbase] = fileparts(prjfile);

    %% Check MATLAB and related tools, e.g.:
    assert( ~verLessThan('MATLAB', '9.5'), 'MATLAB R2018b or higher is required' )

    %% Update Contents.m file

    % extract version from project file
    tver = matlab.addons.toolbox.toolboxVersion(prjfile);

    % read all lines of the Contents file
    contents_file_full = fullfile(cfdir, "tbx", "Contents.m");
    lines = splitlines(string(fileread(contents_file_full))); % string array of lines
    % Assemble version number from release and build number
    release_num = tver; % reuse version number as release number
    date_str    = datestr(now, 1); % execution date in matlab format "dd-mmm-yyyy"
    % New version line for the Contents.m file
    version_line = "% Version " + tver + " " + release_num + " " + date_str;
    fprintf("Version information in Contents.m: %s\n", version_line);
    lines(2) = version_line; % overwrite versions line
    fileID = fopen(contents_file_full, 'w');
    fprintf(fileID, "%s\n", lines); % write modified lines into Contents.m file
    fclose(fileID); % close file

    %% Package
    mltbx = fullfile(cfdir, [prjbase '-' tver '.mltbx']);
    matlab.addons.toolbox.packageToolbox(prjfile, mltbx);

    %% Show message
    fprintf('Created package ''%s''.\n', mltbx);
end
