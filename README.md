# BrazenCloud Powershell Action Developer Kit

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

## Problems

If you run into any problems using the ADK, please reach out to our [Support Team](mailto:support@brazencloud.io) or open an issue in this repository.