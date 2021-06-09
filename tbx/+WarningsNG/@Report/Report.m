classdef Report < handle
    % REPORT objects collect Issue objects and write them into a XML file.
    %
    % The WarningsNG.Report class contains a collection of WarningsNG issues and provides 
    % the translation of the issues into a native WarningsNG XML file.
    %
    % Example:
    %   report = WarningsNG.Report('MyReport.xml'); % creating report object and specify the XML file name
    %   issue = WarningsNG.Issue(); % some issue
    %   report.append(issue);       % add issue to the report
    %   report.xmlwrite();          % write the XML file
    %
    % If the object is destroyed, the XML file is written in the destructor if it was not written before.
    % Calling xmlwrite() my therefor be skipped.

    properties
        % Array of Issue objects
        Issues WarningsNG.Issue = WarningsNG.Issue.empty;

        % The file name to be used if writing to file happens in destructor
        FileName (1,:) char = 'WarningsNG.xml';

        % flag to remember if the content was already saved to the XML file.
        IsSaved logical = false;
    end

    methods
        function obj = Report(varargin)
            % Construct an instance of this class
            %
            % Syntax and description:
            %   report = WarningsNG.Report()
            %      Creates an empty report object.
            %   report = WarningsNG.Report(issues)
            %      Creates a report object with the given Issue objects.
            %   report = WarningsNG.Report(fileName)
            %      Creates an empty report object but specifies the XML file name for saving.
            %   report = WarningsNG.Report(issues, fileName)
            %      Creates a report object with given issues and XML file name.
            %
            % Input Arguments:
            %   issues: array of WarningsNG.Issue objects
            %
            %   fileName: XML file name given as string or char vector is used. If not given, the default file name
            %   "WarningsNG.xml" is used.

            for i=1:nargin
                arg = varargin{i};
                if isa(arg, 'WarningsNG.Issue')
                    obj.Issues   = arg;
                elseif isa(arg,'char') || (isa(arg,'string') && numel(arg)==1)
                    obj.FileName = arg;
                else
                    warning("The argument #%d of type %s cannot be processed.", i, class(arg));
                end
            end
        end

        function delete(obj)
            % Destructor of the instance of the class
            %
            % It writes the issues to the report file if it was not yet done or if the content in memory has changed.

            if ~obj.IsSaved
                obj.xmlwrite();
            end
        end

        function append(obj, newIssues)
            % Append one or more Issue objects to the Issue object array.

            if ~isa(newIssues, 'WarningsNG.Issue')
                warning("The method accepts object of type WarningsNG.Issue only but found type %s.", ...
                    class(newIssues));
                return;
            end

            % append new issues to array of issue objects
            obj.Issues = [ obj.Issues newIssues ];
            obj.IsSaved = false; % mark the content as being not saved.
        end

        function xmlwrite(obj, varargin)
            % Write the object's data content into a WarningsNG XML file.
            %
            % Syntax and description:
            %   report.xmlwrite()
            %      Write the contents to the file with name given in constructor or the default file name.
            %   report.xmlwrite(fileName)
            %      Write the contents to the file with given name.
            %
            % Input Argument:
            %  fileName: File name of the output WarningsNG native xml file. Default: 'WarningsNG.xml'. 
            %            If the .xml suffix is missing, it is appended automatically.
            %
            % Note: The Jenkins WarningsNG plugin issue parser interprets files without .xml ending as JSON files.

            p = inputParser;
            p.addOptional('fileName', '', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}));
            p.parse(varargin{:});

            if ~isempty(p.Results.fileName)
                obj.FileName = p.Results.fileName;
            end

            % append file suffix ".xml" if needed
            [~, ~, ext] = fileparts(obj.FileName);
            if ~strcmpi(ext, '.xml')
                obj.FileName = sprintf('%s.xml', obj.FileName);
            end

            % create document node and document root element node
            docNode = com.mathworks.xml.XMLUtils.createDocument('report');
            docRootNode = docNode.getDocumentElement();

            % create a XML comment that notes the number of issues
            docRootNode.appendChild(docNode.createComment(...
                [' Report contains ' num2str(numel(obj.Issues)) ' WarningsNG issue items ']));

            fields = fieldnames( WarningsNG.Issue() );

            % cycle through array of issue objects and create a xml 'issue' element for each object
            for issue = obj.Issues
                issueElem = docNode.createElement('issue');
                docRootNode.appendChild(issueElem);

                % The Jenkins plugin inserts ...
                % - the Message element content into a html <strong> node and it is interpreted as HTML.
                % - the Description element as HTML that must be wrapped into a HTML paragraph <p> node.
                issue.Message     = WarningsNG.Report.convertAsciiToHtml(issue.Message);
                issue.Description = WarningsNG.Report.convertAsciiToHtmlPara(issue.Description);

                % generate xml elements for each property
                cellfun(@(x) WarningsNG.Report.writeElement(issue, x, issueElem, docNode), fields);
            end

            xmlwrite(obj.FileName, docNode); % write DOM structure into XML file

            obj.IsSaved = true;
        end
    end

    methods (Access=private,Static)

        function writeElement(issue, field, issueElem, docNode)
            % Helper function to generate an xml element as child for a given issue class property

            if isempty(issue.(field))
                return; % ignore empty fields
            end

            % element tags have the same name as the class properties but with the first letter in lower case
            elem_tag_name = [ lower(field(1)) field(2:end) ];

            if isnumeric(issue.(field))
                % Only line numbers are numeric.
                if issue.(field) < 0
                    return; % Create XML element, if the number is not negative.
                end
                element_value_str = num2str(issue.(field));
            else
                % if it is not a numeric type it is always a char array
                element_value_str = issue.(field);
            end

            elem = docNode.createElement(elem_tag_name);
            elem.appendChild(docNode.createTextNode(element_value_str));
            issueElem.appendChild(elem);
        end

        function htmlString = convertAsciiToHtml(asciiString)
            % convert ASCII characters into corresponding HTML entities
            str1       = strrep(asciiString, '<',     '&lt;');
            str2       = strrep(str1,        '>',     '&gt;');
            htmlString = strrep(str2,        newline, '<br/>');
        end

        function htmlString = convertAsciiToHtmlPara(asciiString)
            % convert ASCII string into HTML and wrap result into HTML paragraph
            if isempty(asciiString)
                htmlString = ''; % an empty string will prevent the XML element to be created at all.
            else
                htmlString = [ '<p>' WarningsNG.Report.convertAsciiToHtml(asciiString) '</p>' ];
            end
        end

    end
end
