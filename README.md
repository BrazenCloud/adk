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