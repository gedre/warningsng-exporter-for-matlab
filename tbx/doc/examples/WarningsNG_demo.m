function WarningsNG_demo()

    % create an issue report and add the issue on construction
    report1 = WarningsNG.Report();

    %% Example #1

    % generate an exception by calling a non-existent function
    disp("Example: issue from exception object");
    try
        notaFunction(5,6);
    catch ME
        ex = ME;
    end

    % create an issue object
    exception_issue = WarningsNG.Issue(ex);
    report1.append(exception_issue);

    % create a 2nd report file with non-default file name and initial issues
    report2 = WarningsNG.Report(exception_issue, "Issues");
    % the line above should cause a "variable might be unused" warning.  This is should turn up in Example #6.

    %% Example #2

    disp("Example: self-constructed issue");
    generic_issue = WarningsNG.Issue(...
        'Cat',  'My issue category', ...
        'Ty',   'My issue type', ...
        'Sev',  'LOW', ...
        'Mes',  'My own warning', ...
        'Desc', 'indescribable', ...
        'Mod',  'My module', ...
        'Pack', 'My package');
    report1.append(generic_issue);

    %% Example #3

    disp("Example: issues from Simulink sim run");

    % simulate with invalid stop time.  This causes an error entry in
    % simout.SimulationMetadata.ExecutionInfo.ErrorDiagnostic.Diagnostic
    simout = sim('vdp', ...
        'StopTime',      0, ...
        'CaptureErrors', 'on');
    % extract error issue from Simulink.SimulationMetadata object
    simulink_issue = WarningsNG.Issue(simout.SimulationMetadata);
    report1.append(simulink_issue);

    % run simulation again, but enable "Automatic solver parameter selection" diagnostics, which causes a warning.
    disp("If you see a warning here, that's OK!");
    simout = sim('vdp', ...
        'StopTime',          '1', ...
        'SolverPrmCheckMsg', 'warning', ...
        'CaptureErrors',     'on');
    % extract warning issue from Simulink.SimulationOutput object
    report1.append( WarningsNG.Issue(simout) );

    %% Example #4

    disp("Example: linked exceptions with stack");

    % create a MSL exception object
    MSLEx = MSLException(gcbh, message('Simulink:utility:incompatRotationMirror',5,'test'));
    %ST = dbstack();
    %MSLEx.stack = ST;
    MEx = MException('CauseId:Me','Causing exception');
    MSLEx = MSLEx.addCause(MEx); % add the old exception as cause
    report1.append(WarningsNG.Issue(MSLEx));

    %% Example #5

    % only if TargetLink is installed
    if exist('ds_error_get', 'file')

        disp("Example: issues from TargetLink messages");

        % create example message struct and set some fields
        msg = ds_error_get('MessageStruct', ...
            'type',       'error', ...
            'title',      'Error in API Function', ...
            'msg',        'M-script aborted due to an error', ...
            'ObjectName', '/pipt1/picontroller');

        % A real TargetLink query looks like this:
        %   msg_count = ds_error_check('warning'); % number of TL messages of type 'fatal', 'error', and 'warning'
        %   if msg_count > 0
        %     report1.append( WarningsNG.Issue(ds_error_get('Message', 1:msg_count)) );
        %   end

        tl_issue = WarningsNG.Issue(msg);
        report1.append(tl_issue);
    end

    %% Example #6

    disp("Example: issues from mlint/checkcode");
    
    % all .m files in subdirectories
    filesToCheckStructs = dir(fullfile("..", "**", "*.m"));
    filesToCheck = arrayfun(@(x) string(fullfile(x.folder, x.name)), filesToCheckStructs);

    % Call checkode to lint MATLAB code.
    % Note: checkcode needs to be called with the '-id' option. The returned IDs are also used by the Issue class.
    [info, fp] = checkcode(filesToCheck, '-id');
    % create a struct with both outputs of checkcode for the call of the Issue constructor
    cc.info      = info;
    cc.filepaths = fp;
    report1.append( WarningsNG.Issue(cc) );

    %% write all issues to WarningsNG XML file without file-name override

    report1.xmlwrite();

    % let report2 go out of scope her.  The destructor writes the XML file 'Issues.xml' with one entry.
end
