# BrazenCloud Powershell Action Developer Kit

[![BrazenCloud.ADK](https://img.shields.io/powershellgallery/v/BrazenCloud.ADK.svg?style=flat-square&label=BrazenCloud.ADK "BrazenCloud.ADK")](https://www.powershellgallery.com/packages/BrazenCloud.ADK/)

BrazenCloud's Action Developer Kit provides many useful functions for streamlining Action development.

**Though this ADK is written in PowerShell, it will execute ANY BrazenCloud action.**

You can check out our [Action development guide in the documentation](https://docs.runway.host/runway-documentation/action-developer-guides/overview)

## Install the module

**You must have PowerShell 7.2+**

**Linux Supporting coming soon**

Install the prerequisite module from the PowerShell Gallery:

```powershell
Install-Module BrazenCloud
```

The module can be installed from the PowerShell Gallery:

```powershell
Install-Module BrazenCloud.ADK
```

## Configure for use with VS Code

Install the module and prerequisites. Add this to your `launch.json` configuration:

```json
{
    "name": "Launch BrazenCloud Action",
    "type": "PowerShell",
    "request": "launch",
    "script": "Invoke-BcAction -Path ${file}",
    "cwd": "${workspaceFolder}"
}
```

Now you can `F5` while in a manifest.txt to have it execute in the integrated console.

Be aware that in current state, this will only run the action with default parameters.

If you wish to pass parameters to the Action when you execute it, you can do so with:

```powershell
Invoke-BcAction -Path <path to manifest> -Settings @{parameterName='value',parameter2='blah'}
```

## Usage

To test an unpublished Action locally, you need to have the BrazenCloud PowerShell module installed, then you can:

```powershell
# Build a hashtable of the parameters you want to pass
# Name = Value
$settings = @{
    'Output Type' = 'json'
}
# Path is the path to the action folder or manifest file
# PreserveWorkingDir prevents the cmdlet from clearing out the Action's working directory
$out = Invoke-BcAction -Path C:\path\to\action -Settings $settings -PreserveWorkingDir
```

### Output

Running `Invoke-BcAction` will display a report and a custom `PSObject`.

The report will look similar to:

```plaintext
-------------------------------------------------------------
 ____                           ____ _                 _
| __ ) _ __ __ _ _______ _ __  / ___| | ___  _   _  __| |
|  _ \| '__/ _` |_  / _ \ '_ \| |   | |/ _ \| | | |/ _` |
| |_) | | | (_| |/ /  __/ | | | |___| | (_) | |_| | (_| |
|____/|_|  \__,_/___\___|_| |_|\____|_|\___/ \__,_|\__,_|
-------------------------------------------------------------
Action Invocation Report
-------------------------------------------------------------
Build Process:  No Errors
Run Process:    No Errors
Action Output:  52 lines of stdout. View with '$Out.StdOut'
Results:        No results.

Build            Run              Results StdOut
-----            ---              ------- ------
{StdErr, StdOut} {StdErr, StdOut}         {, Windows IP Configuration, , …}
```

The information should clarify what is in the `PSObject`, but if you need more details, you can reference these properties for the `$out` variable that is automatically created:

```json
{
    "Build": {
        "StdErr": "",
        "StdOut": ""
    },
    "Run": {
        "StdErr": "",
        "StdOut": ""
    },
    "Results": "",
    "StdOut": ""
}
```

- The `Build` property contains the stderr and stdout from building the Action using `runway build`
- The `Run` property contains the stderr and stdout from running the Action using `runner run`
- The `Results` property contains the `FileInfo` object for the results file.
- The `StdOut` property contains the entire stdout for the Action execution.

You can manually capture the output in a variable or you can use the automatic variable: `$out`:

## Problems

If you run into any problems using the ADK, please reach out to our [Support Team](mailto:support@brazencloud.io) or open an issue in this repository.

## Changelog

### 0.2.0

- No longer requires an installed BrazenCloud agent. Instead, it will launch a temporary [node](https://docs.runway.host/runway-documentation/general-concepts/what-is-a-brazenagent#temporary-node-brazenagents) agent.
- Now requires PowerShell 7.2+
- Added a basic report that displays after the action completes execution.
- Fixed WorkingDirectory checks and now properly outputs it to the output variable.
- Improved stdout capture. There were cases where some lines were not captured.
- Prevents reading settings json errors by supplying empty strings for any passed parameters
  - Prevent this with `-SkipMissingParameters`

### 0.1.1

- Fixed `PreserveWorkingDirectory` and `WorkingDirectory` parameters.

### 0.1.0

- Added templates for PowerShell based Actions
- `Invoke-BcAction` improvements:
  - Dynamically generates unique working directory
  - Improved path handling to account for relative paths (fixes #1)
  - Improved results handling
  - Improved redirection file handling
  - Halts on build or run errors
  - Implemented should process
  - Checks for mandatory parameters
  - Adds the generated working directory to the output if `-PreserveWorkingDirectory` is used

### 0.0.2

- Improves the `settings.json` impersonation to include values from the local system.

### 0.0.1

- Initial release, supports local action testing.