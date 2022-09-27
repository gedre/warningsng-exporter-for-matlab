function run_demo()
    % run the demo script from the WarningsNG Exporter toolbox installation directory

    issue_class_file = fileparts(which('WarningsNG.Issue')); % get installation directory of Issue class file
    % construct the relative path to the demos script. Is there a more elegant way to determine the base installation
    % directory of a toolbox?
    demo_src_dir = fullfile(issue_class_file, "..", "..", "doc", "demo");

    demo_tar_dir = tempname(".");

    % copy demo to local directory to prevent running in the original installation directory
    disp("Populating new demo directory copy");
    copyfile(demo_src_dir, demo_tar_dir);
    disp("... done");

    disp("Changing into new demo directory copy");
    old_dir = cd(demo_tar_dir);
    disp("... done: " + demo_tar_dir);

    disp("Running demo live script");
    WarningsNG_demo
    disp("... done");

    disp("Output files:");
    dir("*.xml");

    disp("Changing into new demo/m directory copy");
    cd("m");
    disp("... done");

    disp("Running demo m script");
    WarningsNG_demo
    disp("... done");

    disp("Changing to old directory");
    cd(old_dir);
    disp("... done");
end
