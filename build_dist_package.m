function build_dist_package()
    % Build the MATLAB toolbox distribution package.
    % The release version is copied form the project file into the 'Contents.m' file.

    % Docs on Toolbox Distribution:
    % web(fullfile(docroot, 'matlab/creating-help.html?s_tid=CRUX_lftnav'))

    cfdir = fileparts( mfilename('fullpath') ); % Get script directory

    disp("Looking for project file");
    prj_file_struct = dir(fullfile(cfdir, "*.prj")); % determine the prj file name, returns a struct
    prj_file_full = fullfile(prj_file_struct(1).folder, prj_file_struct(1).name);
    disp("... done: " + prj_file_full);

    [~, prjbase] = fileparts(prj_file_full); % extract project base name form project file name

    %% Check MATLAB and related tools, e.g.:
    disp("Checking MATLAB version");
    assert( ~verLessThan('MATLAB', '9.5'), 'MATLAB R2018b or higher is required' );
    disp("... done");

    %% Update Contents.m file

    disp("Extracting toolbox version from " + prj_file_full);
    tver = matlab.addons.toolbox.toolboxVersion(prj_file_full); % extract version from project file
    disp("... done: version " + tver);

    % read all lines of the Contents file
    disp("Reading Contents.m");
    contents_file_full = fullfile(cfdir, "tbx", "Contents.m");
    lines = splitlines(string(fileread(contents_file_full))); % string array of lines
    disp("... done");

    % use file date of project file
    disp("Getting file date of " + prj_file_full)
    d = datetime(prj_file_struct(1).datenum, 'ConvertFrom', 'datenum', 'Format', 'dd-MMM-yyyy');
    date_str = string(d); 
    disp("... done: " + date_str);

    release_num = tver; % reuse version number as release number

    % New version line for the Contents.m file
    lines(2) = "% Version " + tver + " " + release_num + " " + date_str;

    disp("Setting version information in Contents.m");
    fileID = fopen(contents_file_full, 'w');
    assert(fileID > -1);
    fwrite(fileID, strtrim(lines.join(newline))); % write modified lines into Contents.m file
    fclose(fileID); % close file
    disp("... done: " + lines(2));

    %% Export demo live script as html page
    file_base = fullfile(cfdir, "tbx", "doc", "demo", "WarningsNG_demo");
    disp("Generating demo .html file");
    % do not run the live script here.  This is done in the run_demo.m script.
    % export() was introduced with 2022a
    demo_file = export(file_base + ".mlx", file_base + ".html", Run=false);
    disp("... done: " + demo_file);
    disp("Generating demo .m file");
    demo_file = export(file_base + ".mlx", file_base + ".m", Run=false);
    disp("... done: " + demo_file);

    %% Package
    mltbx = fullfile(cfdir, [prjbase '-' tver '.mltbx']);
    disp("Creating package " + mltbx);
    matlab.addons.toolbox.packageToolbox(prj_file_full, mltbx);
    disp("... done");
end
