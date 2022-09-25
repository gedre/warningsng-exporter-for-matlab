function run_demo()

    f = fileparts(which('WarningsNG.Issue')); % get installation directory
    demo_file = fullfile(f, '..', '..', 'doc', 'examples', 'WarningsNG_demo.m');
    disp("Running demo script " + demo_file);
    run( fullfile(f, '..', '..', 'doc', 'examples', 'WarningsNG_demo.m') );
end