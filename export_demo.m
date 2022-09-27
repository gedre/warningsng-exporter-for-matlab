function export_demo()
    % export the live script demo into html and m format

    % the export does NOT work within github actions as of 2022-09-27

    %% Export demo live script as html page
    cfdir       = fileparts( mfilename('fullpath') ); % Get script directory
    demo_dir    = fullfile(cfdir, "tbx", "doc", "demo");
    live_script = fullfile(demo_dir, "WarningsNG_demo.mlx");
    html_file   = fullfile(demo_dir, "WarningsNG_demo.html");
    m_dir       = fullfile(demo_dir, "m"); % in another directory to prevent shadowing
    m_script    = fullfile(m_dir, "WarningsNG_demo.m"); % in another directory to prevent shadowing

    disp("Generating demo .html file");
    % do not run the live script here.  This is done in the run_demo.m script.
    % export() was introduced with 2022a
    exported_file = export(live_script, html_file, Run=false);
    disp("... done: " + exported_file);

    disp("Generating demo .m file");
    if ~exist(m_dir, 'dir')
        mkdir(m_dir);
    end
    exported_file = export(live_script, m_script, Run=false);
    disp("... done: " + exported_file);
end