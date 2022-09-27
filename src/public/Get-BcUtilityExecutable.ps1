Function Get-BcUtilityExecutable {
    [cmdletbinding()]
    param ()
    $platform = if (Test-Path 'C:\Program Files (x86)') {
        'windows64'
    } else {
        'windows32'
    }
    Write-Information 'Downloading runway.exe...'
    Invoke-BcDownloadContentPublicFile -Key runway -Platform $platform -OutFile $PSScriptRoot\runway.exe
}