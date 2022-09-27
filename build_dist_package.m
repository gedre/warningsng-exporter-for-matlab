function build_dist_package()
    % Build the MATLAB toolbox distribution package.
    % The release version is copied form the project file into the 'Contents.m' file.

    % Docs on Toolbox Distribution:
    % web(fullfile(docroot, 'matlab/creating-help.html?s_tid=CRUX_lftnav'))

    cfdir = fileparts( mfilename('fullpath') ); % Get script directory

    prj_file_struct = dir(fullfile(cfdir, "*.prj")); % determine the prj file name, returns a struct
    prj_file_full = fullfile(prj_file_struct(1).folder, prj_file_struct(1).name);
    disp("Using project file " + prj_file_full);
    [~, prjbase] = fileparts(prj_file_full); % extract project base name form project file name

    %% Check MATLAB and related tools, e.g.:
    assert( ~verLessThan('MATLAB', '9.5'), 'MATLAB R2018b or higher is required' );

    %% Update Contents.m file

    tver = matlab.addons.toolbox.toolboxVersion(prj_file_full); % extract version from project file
    disp("Using toolbox version " + tver);

    % read all lines of the Contents file
    contents_file_full = fullfile(cfdir, "tbx", "Contents.m");
    lines = splitlines(string(fileread(contents_file_full))); % string array of lines
    % Assemble version number from release and build number
    release_num = tver; % reuse version number as release number
    d = datetime(prj_file_struct(1).datenum, 'ConvertFrom', 'datenum', 'Format', 'dd-MMM-yyyy');
    date_str = string(d); % use file date of project file
    % New version line for the Contents.m file
    lines(2) = "% Version " + tver + " " + release_num + " " + date_str;
    disp("Setting version information in Contents.m: " + lines(2));
    fileID = fopen(contents_file_full, 'w');
    assert(fileID > -1);
    fwrite(fileID, strtrim(lines.join(newline))); % write modified lines into Contents.m file
    fclose(fileID); % close file

    %% Export demo live script as html page
    file_base = fullfile(cfdir, "tbx", "doc", "demo", "WarningsNG_demo");
    demo_file = export(file_base + ".mlx", file_base + ".html");
    disp("Generated html file " + demo_file);

    %% Package
    mltbx = fullfile(cfdir, [prjbase '-' tver '.mltbx']);
    matlab.addons.toolbox.packageToolbox(prj_file_full, mltbx);
    disp("Created package " + mltbx);
end
