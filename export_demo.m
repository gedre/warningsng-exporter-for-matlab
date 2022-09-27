function export_demo()
    % export the live script demo into html and m format

    % the export does NOT work within github actions as of 2022-09-27

    %% Export demo live script as html page
    cfdir = fileparts( mfilename('fullpath') ); % Get script directory
    file_base = fullfile(cfdir, "tbx", "doc", "demo", "WarningsNG_demo");
    disp("Generating demo .html file");
    % do not run the live script here.  This is done in the run_demo.m script.
    % export() was introduced with 2022a
    demo_file = export(file_base + ".mlx", file_base + ".html", Run=false);
    disp("... done: " + demo_file);
    disp("Generating demo .m file");
    demo_file = export(file_base + ".mlx", file_base + ".m", Run=false);
    disp("... done: " + demo_file);
end