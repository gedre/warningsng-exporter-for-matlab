classdef Issue
    % ISSUE objects store warning issues based on the WarningsNG data format.
    %
    % This class offers conversion capabilities to translate Matlab/Simulink error/warning data into the
    % native format of the WarningsNG Jenkins plugin.
    %
    % The convertible data formats are:
    % - MException objects
    % - MSLException objects
    % - Simulink.SimulationOutput objects
    % - Simulink.SimulationMetadata objects
    % - TargetLink message structs
    % - checkcode linter messages
    %
    % The properties of this class contain most data elements that are found in the Issue class of the
    % WarningsNG Jenkins plugin.
    %
    % Implementation of the related class "Issue" within the WarningsNG plugin is found at
    % https://github.com/jenkinsci/analysis-model/blob/master/src/main/java/edu/hm/hafner/analysis/Issue.java

    properties
        % The category of the issue
        Category    (1,:) char = ''

        % The type of the issue
        Type        (1,:) char = ''

        % The severity of the issue.
        %
        % Predefined values known by WarningsNG: 'ERROR', 'HIGH', 'NORMAL', 'LOW'
        Severity    (1,:) char = 'NORMAL'

        % The detailed message of the issue. This must be ASCII text and is converted into valid HTML on export.
        Message     (1,:) char = ''

        % The description for the issue. This must be ASCII text and is converted into valid HTML on export.
        %
        % Note: The description element may not be displayed any mor in newer Jenkins WarningsNG plugin versions.
        Description (1,:) char = ''

        % The ID of the tool that did report this issue
        Origin      (1,:) char = 'MATLAB'

        % The name of the module (or project) that contains this issue
        ModuleName  (1,:) char = ''

        % The name of the package (or name space) that contains this issue
        PackageName (1,:) char = ''

        % The name of the file that contains this issue
        FileName    (1,:) char = ''

        % The first line of this issue (line numbering starts at 1; 0 indicates the whole file).
        % Negative numbers disable the XML export of line numbers
        LineStart   (1,1) int32 = -1

        % The last line of this issue (line numbering starts at 1).
        % Negative numbers disable the XML export of line numbers
        LineEnd     (1,1) int32 = -1

        % the first column of this issue (columns start at 1, 0 indicates the whole line)
        ColumnStart (1,1) int32 = -1

        % the last column of this issue (columns start at 1)
        ColumnEnd   (1,1) int32 = -1
    end

    methods
        function obj = Issue(in, varargin)
            % ISSUE constructs one or more instances of this class.
            %
            % Syntax and description:
            %
            %   issue = WarningsNG.Issue();
            %       Creates one issue object with default properties.
            %   issues = WarningsNG.Issue(diag);
            %       Creates issue objects by extracting information form the MSLDiagnostic object array diag.
            %   issues = WarningsNG.Issue(exception);
            %       Creates issue objects by extracting information form the MSLException or MException object array exception an all causing exceptions.
            %   issues = WarningsNG.Issue(simmeta);
            %       Creates issue objects by extracting diagnostics form the Simulink.SimulationMetadata object simmeta.
            %   issues = WarningsNG.Issue(simout);
            %       Creates issue objects by extracting diagnostics form the Simulink.SimulationOutput object simout.
            %   issues = WarningsNG.Issue(tlmsgs);
            %       Creates issue objects by extracting diagnostics form the TargetLink message struct array tlmsgs.
            %   issues = WarningsNG.Issue(___, prop, value, ...);
            %       Creates issue objects and overwrites class properties as given by the parameter-value pairs. See the class documentation on the properties and the possible values.

            if nargin == 0
                % constructor call with no parameters: construct one object with default properties
                return;
            end

            exInfo = []; % execution information struct, default: none available
            paramArgs = varargin; % take parameters from the function arguments

            % check the first function argument type
            if isa(in, 'MSLDiagnostic')
                % extract issues from MSLDiagnostic objects
                obj = WarningsNG.Issue.MSLDiagnostic2Issue(in, 'NORMAL'); % extend array
            elseif isa(in, 'MException')
                % extract issues from MException and MSLExceptions objects
                obj = WarningsNG.Issue.MException2Issue(in);
            elseif isa(in, 'Simulink.SimulationMetadata')
                % get execution info from SimulationMetadata object and extract issues later
                exInfo = in.ExecutionInfo;
            elseif isa(in, 'Simulink.SimulationOutput')
                % get execution info from SimulationOutput object and extract issues later
                exInfo = in.SimulationMetadata.ExecutionInfo;
            elseif WarningsNG.Issue.isTLMsg(in)
                % extract issues from TargetLink message structs
                obj = WarningsNG.Issue.TLMsg2Issue(in);
            elseif WarningsNG.Issue.isCheckcodeInfo(in)
                % extract issues from checkcode info structs
                obj = WarningsNG.Issue.CheckcodeInfo2Issue(in);
            elseif ~isempty(in)
                % assume, that the first input parameter is part of the parameter list
                paramArgs = [ {in}, varargin ];
            else
                % the first input argument is empty. ignore it
            end

            % if we process simulation outputs ...
            if ~isempty(exInfo)
                % get error/warning diagnostics from simulation metadata
                ed  = exInfo.ErrorDiagnostic; % this contains at most one struct
                wds = exInfo.WarningDiagnostics; % this is an array of structs
                % convert error and warning diagnostics into issues
                if ~isempty(ed)
                    obj = WarningsNG.Issue.MSLDiagnostic2Issue(...
                        ed.Diagnostic, 'ERROR', ed.SimulationPhase, ed.SimulationTime);
                else
                    obj = WarningsNG.Issue.empty; % start with empty object array
                end
                for idx = 1:numel(wds)
                    obj = [ obj WarningsNG.Issue.MSLDiagnostic2Issue(...
                        wds(idx).Diagnostic, 'NORMAL', wds(idx).SimulationPhase, wds(idx).SimulationTime) ]; %#ok<AGROW>
                end
            end

            % prepare parsing of the input parameters
            p = inputParser;
            p.addParameter('Category',    '', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('Type',        '', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('Severity',    '', ...
                @(x) any(validatestring(x, {'ERROR', 'HIGH', 'NORMAL', 'LOW'})));
            p.addParameter('Message',     '', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('Description', '', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('Origin',      '', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('ModuleName',  '', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('PackageName', '', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('FileName',    '', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('LineStart',   -1, ...
                @(x) validateattributes(x,{'numeric'},{'integer','nonnegative'}));
            p.addParameter('LineEnd',     -1, ...
                @(x) validateattributes(x,{'numeric'},{'integer','nonnegative'}));
            p.addParameter('ColumnStart', -1, ...
                @(x) validateattributes(x,{'numeric'},{'integer','nonnegative'}));
            p.addParameter('ColumnEnd', -1, ...
                @(x) validateattributes(x,{'numeric'},{'integer','nonnegative'}));
            % parse the parameter list
            p.parse(paramArgs{:});

            % cycle through valid function parameters
            for i=1:numel(p.Parameters)
                par = p.Parameters{i};
                % check if parameter was used in constructor call
                if ~strcmp('in', par) && ~any(strcmp(p.UsingDefaults, par))
                    % overwrite defaults with given argument for all issue objects
                    for j=1:numel(obj)
                        obj(j).(par) = p.Results.(par);  %#ok<AGROW>
                    end
                end
            end
        end % of constructor

    end % of public methods

    methods(Access=private,Static)

        function issues = MSLDiagnostic2Issue(diagnostics, severity, SimulationPhase, SimulationTime)
            % Append new Issue objects from an array of MSDiagnostic objects and return Issue object array.
            %
            % ARGUMENTS:
            % - diagnostics: object or array of objects of type MSDiagnostic.
            % - severity: char array denoting the issue severity. possible values 'ERROR', 'HIGH', 'NORMAL', or 'LOW'.
            % - SimulationPhase: char array
            % - SimulationTime: double or []

            % Data structure examples:
            %
            % identifier: 'Simulink:DataType:DefaultDataTypeMethodUsedAtPort'
            % message: 'The data types for some signals in this model are under-specified.  blah blah:'
            % paths: {}
            % cause: {20x1 cell}
            % stack: [0x1 struct]
            %
            % identifier: 'Simulink:DataType:DefaultDataTypeMethodUsedAtOutPortBlk'
            % message: 'Signal with under-specified data types: output port 1 of 'some/block'.'
            % paths: {'some/block'}
            % cause: {}
            % stack: [0x1 struct]

            issues = WarningsNG.Issue.empty; % start with empty object array

            for i=1:numel(diagnostics)
                d = diagnostics(i);
                msg_text = MSLDiagnostic.getMsgToDisplay(true, d.message); % remove the markup from text

                % adding info regarding simulation phase and simulation time to the description property
                if ~isempty(SimulationPhase)
                    % The SimulationPhase is a char vector taken from
                    % Simulink.SimulationMetadata.ExecutionInfo.ErrorDiagnostic.SimulationPhase or
                    % Simulink.SimulationMetadata.ExecutionInfo.WarningDiagnostics().SimulationPhase.

                    % append to message text
                    msg_text = [ msg_text newline 'Simulation phase: ' SimulationPhase ]; %#ok<AGROW>
                end
                if ~isempty(SimulationTime)
                    % SimulationTime is a double value taken from
                    % Simulink.SimulationMetadata.ExecutionInfo.ErrorDiagnostic.SimulationTime or
                    % Simulink.SimulationMetadata.ExecutionInfo.WarningDiagnostics().SimulationTime
                    msg_text = sprintf("%s\nSimulation time : %f", msg_text, SimulationTime);
                end

                % create new issue object
                issue = WarningsNG.Issue( ...
                    'Type',        d.identifier, ...
                    'Severity',    severity, ...
                    'Message',     strtrim(msg_text), ... 
                    'Category',    'MATLAB/Simulink Diagnostics', ...
                    'Origin',      'Simulink');

                if ~isempty(d.stack)
                    % Note: the stack structure consists of the fields 'file' (char), 'name' (char), 'line' (double).
                    % We only report the top most element and we ignore the function name.
                    issue.FileName  = d.stack(1).file;
                    issue.LineStart = d.stack(1).line;
                    issue.LineEnd   = d.stack(1).line;
                    % append stack trace to issue message
                    issue.Message = [ msg_text newline WarningsNG.Issue.StackTrace2CharVec(d.stack) ];
                end
                if ~isempty(d.paths)
                    for j=1:numel(d.paths)
                        % add new issue entry with path set in ModuleName field for each affected path
                        issue.ModuleName = d.paths{j};
                        issues(end+1) = issue; %#ok<AGROW>
                    end
                else
                    % add entry without module/path
                    issues(end+1) = issue; %#ok<AGROW>
                end
                if ~isempty(d.cause)
                    % recursively add causing diagnostics
                    causing_diags = [ d.cause{:} ]; % transform cells with objects into array of objects
                    issues = [ issues WarningsNG.Issue.MSLDiagnostic2Issue(causing_diags, severity) ]; %#ok<AGROW>
                end
            end
        end

        function issues = MException2Issue(exceptions)
            % Append new Issue objects from an array of MException or MSLException objects
            % and return Issue object array.

            % Data structure examples:
            %
            % handles: {1x0 cell}
            % identifier: 'MATLAB:MException:MultipleErrors'
            % message: 'Error due to multiple causes.'
            % cause: {2x1 cell}
            % stack: [1x1 struct]
            %
            % handles: {[6.0001]}
            % identifier: 'Simulink:Engine:OutputNotConnected'
            % message: 'Output port 1 of 'some/block' is not connected.'
            % cause: {0x1 cell}
            % stack: [1x1 struct]

            issues = WarningsNG.Issue.empty; % start with empty object array

            for i = 1:numel(exceptions)
                ex = exceptions(i);

                % Remove the hyperlinks from the Exception message as these can only be used on the MATLAB console.
                % MException.getReport() does not remove all html tags. We use MSLDiagnostic.getMsgToDisplay() in
                % addition here.
                msg_text = MSLDiagnostic.getMsgToDisplay(true, ex.getReport('extended', 'hyperlinks', 'off'));

                % create new issue object
                issue = WarningsNG.Issue(...
                    'Type',        ex.identifier, ...
                    'Severity',    'ERROR', ...
                    'Message',     strtrim(msg_text));

                if ~isempty(ex.stack)
                    % Note: the stack structure consists of the fields 'file', 'name', 'line'.  We only report the top
                    % most element and we ignore the function name.
                    issue.FileName  = ex.stack(1).file;
                    issue.LineStart = ex.stack(1).line;
                    issue.LineEnd   = ex.stack(1).line;

                    % append stack trace to issue message
                    issue.Message = [ msg_text newline WarningsNG.Issue.StackTrace2CharVec(ex.stack) ];
                end

                % differentiate between MATLAB/Simulink and MATLAB exceptions
                if isa(ex, 'MSLException')
                    issue.Category = 'MATLAB/Simulink Exception';
                    issue.Origin   = 'Simulink';
                    % for MSLExceptions there is the additional field 'handles' which point to the model block causing
                    % the problem.
                    full_names = getfullname([ex.handles{:}]);
                    % getfullname returns cells of char vectors or a char vector
                    if ~iscell(full_names)
                        full_names = { full_names };
                    end
                    if ~isempty(full_names)
                        for j=1:numel(full_names)
                            % add new issue entry for each affected block.  These are copies of the constructed issue
                            % which only differ in the ModuleName property.
                            issue.ModuleName = full_names{j};
                            issues(end+1) = issue; %#ok<AGROW>
                        end
                    else
                        % if no handles are given, add issue without defined ModuleName
                        issues(end+1) = issue; %#ok<AGROW>
                    end
                else % ex is a MException
                    issue.Category = 'MATLAB Exception';
                    issue.Origin   = 'MATLAB';
                    issues(end+1) = issue; %#ok<AGROW>
                end

                if ~isempty(ex.cause)
                    % recursively add causing exceptions
                    causing_exceptions = [ ex.cause{:} ]; % transform cells with objects into array of objects
                    issues = [ issues WarningsNG.Issue.MException2Issue(causing_exceptions) ]; %#ok<AGROW>
                end
            end
        end

        function flag = isTLMsg(in)
            % check if input is a struct array of TL messages

            % TL message structs look like this:
            % type          Message type: 'fatal', 'error', 'warning', 'advice', or 'note'. Default: 'error'
            % number        Message number. Default: 0
            % title         Message title.  Default: ''
            % msg           Message.        Default: ''
            % objectName    Name of Simulink block, Stateflow object, DD object, file or MATLAB variable related to
            %               message. Default: ''
            % objectHandle  Handle of Simulink block, Stateflow object or DD object related to message.
            %               Default: []
            % module        Name of the module (M file) which produced the message. Default: ''
            % fcn           Name of subfunction in module (M file). Default: ''
            % line          Code line number in the module (M file) which produced the message. Default: -1
            % clock         Date and time the message was produced with the date returned by MATLAB's now function.
            %               Default: 'now'
            % confirmed     If 1, user-confirmed message. Default: 0
            % objectKind    Type of object related to message, as specified with objectName or objectHandle:
            %               'slblock': Simulink block, 'sfobject': Stateflow object, 'ddobject': Data Dictionary object,
            %               'file': File name, 'mxarray': MATLAB variable.  Default: 'slblock'
            if ~isa(in, 'struct')
                flag = false;
                return
            end
            % check if the fields we access later are available
            f = isfield(in, {'type', 'number', 'title', 'msg', 'objectName', 'module', 'fcn', 'line', 'objectKind'});
            flag = all(f);
        end

        function issues = TLMsg2Issue(tlMsgs)
            % Create WarningsNG issue objects form TargetLink messages

            issues = WarningsNG.Issue.empty; % start with empty object array

            % Cycle through all fatal, errors, warnings, and advices
            for i = 1:numel(tlMsgs)
                % assemble the error/warning ID as displayed by the TL diagnostics window.
                % pattern: [FEWAN]\d{5}
                issueType   = sprintf('%c%05d', upper(tlMsgs(i).type(1)), tlMsgs(i).number);

                % do a simple mapping of TargetLink message types to issue severities:
                %  fatal and errors  -> ERROR
                %  warning           -> NORMAL
                %  advices and notes -> LOW
                switch issueType(1)
                    case {'F','E'}
                        severity = 'ERROR';
                    case {'W'}
                        severity = 'NORMAL';
                    otherwise
                        severity = 'LOW';
                end

                msg_text = tlMsgs(i).title;

                % extend issue message from other TL message struct fields if they are not empty
                if ~isempty(tlMsgs(i).objectName)
                    msg_text = sprintf([ ...
                        '%s' newline ...
                        'ObjectName: %s' newline ...
                        'ObjectKind: %s'], ...
                        msg_text, tlMsgs(i).objectName, tlMsgs(i).objectKind);
                end

                % create new issue object
                issue = WarningsNG.Issue(...
                    'Type',        issueType, ...
                    'Severity',    severity, ...
                    'Message',     strtrim(msg_text), ...
                    'Origin',      'TargetLink', ...
                    'Category',    'TargetLink messages');

                % if module (i.e. the file) is given write this into the matching issue properties
                if ~isempty(tlMsgs(i).module) && ~strcmp(tlMsgs(i).module, 'unknown')
                    issue.FileName  = tlMsgs(i).module;
                    issue.LineStart = tlMsgs(i).line;
                    issue.LineEnd   = tlMsgs(i).line;
                    issue.Message   = sprintf([ ...
                        '%s' newline ...
                        'Module    : %s' newline ...
                        'Function  : %s' newline ...
                        'Line      : %d'], ...
                        msg_text, tlMsgs(i).module, tlMsgs(i).fcn, tlMsgs(i).line);
                end

                % append to list of issues
                issues(end+1) = issue; %#ok<AGROW>
            end
        end

        function str = StackTrace2CharVec(stack)
            % assemble text (char array) containing the stack trace

            str = 'Stack Trace:';
            for k = 1:numel(stack)
                str = sprintf([
                    '%s' newline ...
                    'file: %s' newline ...
                    'name: %s' newline ...
                    'line: %d'], ...
                    str, stack(k).file, stack(k).name, stack(k).line);
            end
        end

        function flag = isCheckcodeInfo(in)
            % check if input is an array of structs constructed form the checkcode() outputs

            % checkcode structs look like this:
            % id: 'NASGU'
            % message: 'The value assigned to variable 'nothandle' might be unused.'
            % fix: 0
            % line: 21
            % column: [1 9]

            if ~isstruct(in)
                flag = false;
                return
            end
            % check if the fields we access later are available
            f = isfield(in, {'info', 'filepaths'});
            if ~all(f)
                flag = false;
                return
            end
            if ~isstruct(in.info) || ~iscellstr(in.filepaths)
                flag = false;
                return
            end
            if numel(in.info) ~= numel(in.filepaths)
                flag = false;
                return;
            end
            f = isfield(in.info, {'id', 'message', 'line', 'column'});
            flag = all(f);
        end

        function issues = CheckcodeInfo2Issue(checkcode)
            % Create WarningsNG issue objects form checkcode info struct
            %
            % Arguments:
            % - checkcode: a struct array with 2 fields 'info' and 'filepaths'
            %              corresponding to the 2 outputs of the checkcode() function. 

            issues = WarningsNG.Issue.empty; % start with empty object array

            % Cycle through all info entries
            for fileIdx = 1:numel(checkcode.info)
                if iscell(checkcode.info)
                    ccMsgs = checkcode.info{fileIdx};
                else
                    ccMsgs = checkcode.info;
                end
                fp   = checkcode.filepaths{fileIdx};

                % cycle through all checkcode messages
                for msgIdx = 1:numel(ccMsgs)
                    info =  ccMsgs(msgIdx);
                    % cycle through all lines this msg applies to
                    for lineIdx = 1:numel(info.line)
                        issues(end+1) = WarningsNG.Issue(...
                            'Type',        info.id, ...
                            'Message',     info.message, ...
                            'Origin',      'checkcode', ...
                            'Category',    'checkcode messages', ...
                            'FileName',    fp, ...
                            'LineStart',   info.line(lineIdx), ...
                            'LineEnd',     info.line(lineIdx), ...
                            'ColumnStart', info.column(lineIdx,1), ...
                            'ColumnEnd',   info.column(lineIdx,2) ); %#ok<AGROW>
                    end
                end
            end
        end
    end
end
