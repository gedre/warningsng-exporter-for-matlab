# WarningsNG Exporter for MATLAB

[![View WarningsNG Exporter on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://de.mathworks.com/matlabcentral/fileexchange/93755-warningsng-exporter)
[![Run Demo in Matlab](https://github.com/gedre/warningsng-exporter-for-matlab/actions/workflows/run_demo_in_matlab.yml/badge.svg)](https://github.com/gedre/warningsng-exporter-for-matlab/actions/workflows/run_demo_in_matlab.yml)

The [Jenkins Warnings Next Generation Plugin](https://github.com/jenkinsci/warnings-ng-plugin) collects compiler warnings or issues of static analysis tools and visualizes the results.

The **WarningsNG Exporter for MATLAB** is a MATLAB&reg; toolbox and provides a converter for diagnostic messages into the native WarningsNG XML format that can be read by the Jenkins WarningsNG plugin.  The converter is intended to be used from within MATLAB scripts that are called as part of a Jenkins CI jobs, e.g. with the help of the [Jenkins MATLAB Plugin](https://github.com/mathworks/jenkins-matlab-plugin).

MATLAB and Simulink&reg; provide own methods to display and manage warnings, errors and other diagnostic messages.
Currently, the exporter supports the conversion of the following data:
* Thrown exceptions from MATLAB code (`MException` and `MSLException` objects)
* Output of Simulink simulation runs (`Simulink.SimulationOutput` and `Simulink.SimulationMetadata` objects)
* dSPACE TargetLink&reg; code generator diagnostics message structures
* `checkcode` linter messages

In addition, generic warning issues can be created by setting individual issue properties directly.

## Requirements

The exporter works with MATLAB R2018b and later.  The support for dSPACE TargetLink is optional.

See the [Jenkins Warnings Next Generation Plugin](https://github.com/jenkinsci/warnings-ng-plugin) for the requirements of the plugin.

## Installation

To install a package after download, open MATLAB, navigate to the mltbx file and double-click on it.  The toolbox is installed and shows up in MATLAB's Add-On Manager.

## Structure

The exporter defines two classes, `Report` and `Issue`, within the namespace `WarningsNG`.  The `WarningsNG.Issue` class represents individual issues in the [WarningNG issue data model](https://github.com/jenkinsci/analysis-model/blob/master/src/main/java/edu/hm/hafner/analysis/Issue.java).
The `WarningsNG.Report` class collects of WarningsNG issues and provides the translation of the issues into the native WarningsNG XML file.

## Examples

The following MATLAB code snippets illustrate the use of the exporter.

Creating an generic issue object:
```matlab
issue = WarningsNG.Issue(...
    'Category', 'Style', ...
    'Type',     'W123', ...
    'Severity', 'LOW', ...
    'Message',  'My own warning');
```

Adding issues to reports and writing to XML file:
```matlab
report = WarningsNG.Report();
report.append(issue);
report.xmlwrite();
```

Exporting Simulink warnings from Simulink runs:
```matlab
simout = sim('MySim', 'CaptureErrors', 'on');
report = WarningsNG.Report(WarningsNG.Issue(simout), "Simulink_Warnings.xml");
report.xmlwrite();
```

Exporting dSPACE TargetLink messages:
```matlab
report = WarningsNG.Report();
msg_count = ds_error_check('warning');
if msg_count > 0
   report.append( WarningsNG.Issue(ds_error_get('Message', 1:msg_count)) );
end
report.xmlwrite();
```

See the [MATLAB demo script](tbx/doc/examples/WarningsNG_demo.m) and the [Jenkinsfile](tbx/doc/examples/Jenkinsfile) for further application examples.

## Further Documentation

Display the class documentation in MATLAB with
```matlab
doc WarningsNG.Issue
doc WarningsNG.Report
```

