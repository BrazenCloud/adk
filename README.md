# BrazenCloud Powershell Action Developer Kit

[![Runway](https://img.shields.io/powershellgallery/v/BrazenCloud.ADK.svg?style=flat-square&label=BrazenCloud.ADK "BrazenCloud.ADK")](https://www.powershellgallery.com/packages/BrazenCloud.ADK/)

BrazenCloud's Action Developer Kit provides many useful functions for streamlining Action development.

You can check out our [Action development guide in the documentation](https://docs.runway.host/runway-documentation/action-developer-guides/overview)

## Install the module

The module can be installed from the PowerShell Gallery:

```powershell
Install-Module BrazenCloud.ADK
```

## Usage

Currenty the ADK supports 2 use cases:

- Finding the installed BrazenAgent path
- Testing an unpublished Action locally

To find the installed BrazenAgent paths:

```PowerShell
# Return as a DirectoryInfo object
Get-BcAgentInstallPath

# Return as a string
Get-BcAgentInstallPath -AsString
```

To test an unpublished Action locally, you need to have the BrazenCloud utility downloaded, then you can run the Action with:

```powershell
# Build a hashtable of the parameters you want to pass
# Name = Value
$settings = @{
    'Output Type' = 'json'
}
# Path is the path to the action folder or manifest file
# UtilityPath is the path to the BrazenCloud utility
# PreserveWorkingDir prevents the cmdlet from clearing out the Action's working directory
$out = Invoke-BcAction -Path C:\path\to\action -UtilityPath C:\path\to\runway.exe -Settings $settings -PreserveWorkingDir
```

### Output

Running `Invoke-BcAction` produces a custom `PSObject` that has the following properties:

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