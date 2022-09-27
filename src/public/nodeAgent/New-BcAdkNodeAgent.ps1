Function New-BcAdkNodeAgent {
    [cmdletbinding()]
    param (

    )
    if (-not (Get-BcAdkNodeAgent)) {
        try {
            Get-BcAuthenticationCurrentUser -ErrorAction Stop | Out-Null
        } catch {
            Throw "Unauthorized. Authenticate using 'Connect-BrazenCloud' first."
        }
        $tokenSplat = @{
            Expiration = (Get-Date).AddMinutes(30)
            IsOneTime  = $false
            Type       = 'EnrollPersistentRunner'
            GroupId    = (Get-BcAuthenticationCurrentUser).HomeContainerId
        }
        $token = New-BcEnrollmentSession @tokenSplat
        if (-not (Test-Path $PSScriptRoot\runway.exe)) {
            Get-BcUtilityExecutable
        }
        Push-Location
        Set-Location $PSScriptRoot
        Get-Location
        $global:BrazenCloudAdkNodeAgentId = (New-Guid).Guid
        $global:NodeAgentProcess = [System.Diagnostics.Process]::new()
        $NodeAgentProcess.StartInfo.RedirectStandardOutput = $true
        $NodeAgentProcess.StartInfo.RedirectStandardError = $true
        $NodeAgentProcess.StartInfo.Arguments = @('-S', $env:BrazenCloudDomain, 'node', '-t', $token.Token, '--customid', $BrazenCloudAdkNodeAgentId)
        $NodeAgentProcess.StartInfo.WindowStyle = 'Hidden'
        $NodeAgentProcess.StartInfo.WorkingDirectory = $PSScriptRoot
        $NodeAgentProcess.StartInfo.FileName = "runway.exe"
        $NodeAgentProcess.Start()
        Pop-Location
        
        $noDir = $true
        $x = 0
        While ($noDir) {
            Get-ChildItem -Directory | ForEach-Object {
                if ($_.Name -match '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
                    $global:NodeAgentPath = Get-Item $_.FullName
                    $noDir = $false
                }
            }
            Start-Sleep -Seconds 1
            $x++
            if ($x -ge 10 -or $NodeAgentProcess.HasExited) {
                Write-Host 'Node failed to start.'
                $noDir = $false
            }
        }
    }
}