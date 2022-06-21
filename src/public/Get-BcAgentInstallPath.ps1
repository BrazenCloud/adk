Function Get-BcAgentInstallPath {
    [OutputType([System.IO.DirectoryInfo], ParameterSetName = 'dirInfo')]
    [OutputType([System.String], ParameterSetName = 'str')]
    [cmdletbinding(
        DefaultParameterSetName = 'dirInfo'
    )]
    param (
        [Parameter(
            ParameterSetName = 'str'
        )]
        [switch]$AsString
    )
    if ($AsString.IsPresent) {
        Get-ChildItem 'C:\Program Files\Runway' | ForEach-Object { $_.FullName }
    } else {
        Get-ChildItem 'C:\Program Files\Runway'
    }
}