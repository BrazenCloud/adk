Function Get-BcAdkNodeAgent {
    [cmdletbinding()]
    param (

    )
    $ht = @{
        IsRunning = $false
        Process   = $NodeAgentProcess
        Path      = $NodeAgentPath
    }
    if (Get-Variable -Scope Script -Name NodeAgentProcess -ErrorAction SilentlyContinue) {
        if ( -not $NodeAgentProcess.HasExited) {
            $ht['IsRunning'] = $true
        }
    }
    New-Object psobject -Property $ht
}