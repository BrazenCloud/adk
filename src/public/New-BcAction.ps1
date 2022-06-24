Function New-BcAction {
    [cmdletbinding(SupportsShouldProcess)]
    param (
        [string]$TemplateName = 'PowerShellAction',
        [Parameter(
            Mandatory,
            HelpMessage = 'Parent path of the action.'
        )]
        [string]$Destination,
        [switch]$Force
    )
    if (-not (Get-Module Plaster -ListAvailable)) {
        if ($Force.IsPresent) {
            Install-Module Plaster -Repository PsGallery -Force
        } else {
            Write-Warning 'This command requires the Plaster module. Please install or use the -Force switch to automatically isntall.'
            return
        }
    }
    Invoke-Plaster -TemplatePath $PSScriptRoot\templates\$TemplateName -DestinationPath $Destination
}