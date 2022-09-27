%% Demo for using the WarningsNG classes
% Create an initially empty issue report object |report1|. The resulting file 
% will have the default file name |WarningsNG.xml|.

report1 = WarningsNG.Report();
%% Example #1: issue from exception object
% Generate an exception by calling a non-existent function

try
    notaFunction(5,6); % this will throw an exception
catch ME
    ex = ME;
end
%% 
% Create an |Issue| object from the exception and append it to the report

exception_issue = WarningsNG.Issue(ex);
report1.append(exception_issue);
%% 
% Create a 2nd report object and provide a non-default file name (|Report2_Issues.xml|) 
% and a first |Issue| object to the constructor. The file extension |.xml| is 
% used if it is not given.

report2 = WarningsNG.Report(exception_issue, "Report2_Issues");
%% Example #2: self-constructed issue

generic_issue = WarningsNG.Issue(...
    'Cat',  'My issue category', ...
    'Ty',   'My issue type', ...
    'Sev',  'LOW', ...
    'Mes',  'My own warning', ...
    'Desc', 'indescribable', ...
    'Mod',  'My module', ...
    'Pack', 'My package');
report1.append(generic_issue);
%% Example #3: issues from Simulink sim run
% Run the simulation with an invalid stop time.  This produces an error entry 
% in |simout.SimulationMetadata.ExecutionInfo.ErrorDiagnostic.Diagnostic|. 

simout = sim('vdp', 'StopTime', 0, 'CaptureErrors', 'on');
%% 
% Extract error issue from |Simulink.SimulationMetadata| object and append it 
% to |report1|.

simulink_issue = WarningsNG.Issue(simout.SimulationMetadata);
report1.append(simulink_issue);
%% 
% Run simulation again, but enable "Automatic solver parameter selection" diagnostics, 
% which causes a warning. It is OK, if you see a warning below!

simout = sim('vdp', 'StopTime', '1', 'SolverPrmCheckMsg', 'warning', 'CaptureErrors', 'on');
%% 
% Create a new |Issue| object and extract the warning from the |Simulink.SimulationOutput| 
% object |simout| during constructor call. Append the |Issue| object to |report1|.

report1.append( WarningsNG.Issue(simout) );
%% Example #4: linked exceptions with stack
% Create a MSL exception object and a

MSLEx = MSLException(gcbh, message('Simulink:utility:incompatRotationMirror',5,'test'));
%% 
% Create an exception object and add it as causing exception to |MSLEx|.

MEx   = MException('CauseId:Me','Causing exception');
MSLEx = MSLEx.addCause(MEx);
%% 
% Create a new |Issue| object and extract the warning from the |MSLException| 
% object during constructor call. Append the |Issue| object to |report1|.

report1.append( WarningsNG.Issue(MSLEx) );
%% 
% Close the vdp model again and discard all changes. This was only needed for 
% example #3 and #4.

bdclose('vdp');
%% Example #5: issues from mlint/checkcode
% Run |checkcode| in a dummy script file to demonstrate mlint warnings

issue_class_file = fileparts(which('WarningsNG.Issue')); % get installation directory of Issue class file
demo_dir         = fullfile(issue_class_file, "..", "..", "doc", "demo");
filesToCheck     = fullfile(demo_dir, "dummy_script.m");
%% 
% If you want to check all your |.m| and |.mlx| in some directory, you may analyse 
% them in a loop like this.

for f = filesToCheck
%% 
% Call checkcode to lint MATLAB code.  Note: checkcode needs to be called with 
% the '|-id|' option. The returned IDs are also used by the Issue class.

    [info, fp] = checkcode(f, '-id');
%% 
% Create a struct with both outputs of checkcode for the call of the |Issue| 
% constructor.

    cc.info         = info; % the warnings for file f
    cc.filepaths    = cell(size(info));
    cc.filepaths(:) = fp;   % set the same filename for each warning
    report1.append( WarningsNG.Issue(cc) );
end
%% Example #6: issues from TargetLink messages

if exist('ds_error_get', 'file') % check if TargetLink is installed
%% 
% Create example message struct and set some fields

    msg = ds_error_get('MessageStruct', ...
        'type',       'error', ...
        'title',      'Example TargetLink Error', ...
        'msg',        'This is an example error message to demonstrate the WarningsNG Exporter for TargetLink', ...
        'ObjectName', '/pipt1/picontroller');
%% 
% A real TargetLink query for errors/warnings looks like this:
% 
% |msg_count = ds_error_check('warning');|
% 
% |if msg_count > 0|
% 
% |report1.append( WarningsNG.Issue(ds_error_get('Message', 1:msg_count)) );|
% 
% |end|
% 
% Create an |Issue| object from the TargetLink error message  and add it to 
% |report1|.

    tl_issue = WarningsNG.Issue(msg);
    report1.append(tl_issue);
end
%% Write to file
% Write all issues in |report1| into a WarningsNG XML file.  Here, the default 
% xml file-name is used.

report1.xmlwrite();
%% 
% If a Report object gets out of scope at the end of a function, the destructor 
% is called.  As part of the destructor call, the XML file is written if this 
% did not happen before.
% 
% Here we provoke the destructor call by deleting the object explicitly.  The 
% file |Issues.xml| is written with one entry.

delete(report2);
%% 
% Look into files |Report2_Issues.xml| and |WarningsNG.xml| to see the results 
% of the demo.