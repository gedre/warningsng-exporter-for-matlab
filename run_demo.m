function run_demo()
    % run the demo script from the WarningsNG Exporter toolbox installation directory

    issue_class_file = fileparts(which('WarningsNG.Issue')); % get installation directory of Issue class file
    % construct the relative path to the demos script. Is there a more elegant way to determine the base installation
    % directory of a toolbox?
    demo_dir  = fullfile(issue_class_file, "..", "..", "doc", "demo");
    demo_file = fullfile(demo_dir, "WarningsNG_demo.mlx");

    disp("Cleaning demo outputs");
    delete(fullfile(demo_dir, "*.xml"));

    disp("Running demo script " + demo_file);
    run(demo_file);
    % script is executed in the path of the script!

    disp("Output files:");
    dir(fullfile(demo_dir, "*.xml"));
end