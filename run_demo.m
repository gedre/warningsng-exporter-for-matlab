function run_demo()
    % run the demo script from the WarningsNG Exporter toolbox installation directory

    issue_class_file = fileparts(which('WarningsNG.Issue')); % get installation directory of Issue class file
    % construct the relative path to the demos script. Is there a more elegant way to determine the base installation
    % directory of a toolbox?
    demo_m_dir = fullfile(issue_class_file, "..", "..", "doc", "demo", "m");
    demo_m_file  = fullfile(demo_m_dir, "WarningsNG_demo.m");

    disp("Cleaning demo outputs");
    files_to_delete = fullfile(demo_m_dir, "*.xml");
    delete(files_to_delete);
    disp("... done: " + files_to_delete);

    disp("Running demo script " + demo_m_file);
    run(demo_m_file); % script is executed in the path of the script
    disp("... done");

    disp("Output files:");
    dir(fullfile(demo_m_dir, "*.xml"));
end
