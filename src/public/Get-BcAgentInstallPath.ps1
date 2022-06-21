Function Get-BcAgentInstallPath {
    [cmdletbinding()]
    param (
        [switch]$AsString
    )
    if ($AsString.IsPresent) {
        Get-ChildItem 'C:\Program Files\Runway' | ForEach-Object { $_.FullName }
    } else {
        Get-ChildItem 'C:\Program Files\Runway'
    }
}