Function Start-BcAdkNodeAgent {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [cmdletbinding(SupportsShouldProcess)]
    param (

    )
    if (-not (Get-BcAdkNodeAgent).IsRunning) {
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
        $script:BrazenCloudAdkNodeAgentId = (New-Guid).Guid
        $script:NodeAgentProcess = [System.Diagnostics.Process]::new()
        $NodeAgentProcess.StartInfo.RedirectStandardOutput = $true
        $NodeAgentProcess.StartInfo.RedirectStandardError = $true
        $NodeAgentProcess.StartInfo.Arguments = @('-S', $env:BrazenCloudDomain, 'node', '-t', $token.Token, '--customid', $BrazenCloudAdkNodeAgentId, '--new')
        $NodeAgentProcess.StartInfo.WindowStyle = 'Hidden'
        $NodeAgentProcess.StartInfo.WorkingDirectory = $PSScriptRoot
        $NodeAgentProcess.StartInfo.FileName = "runway.exe"
        $NodeAgentProcess.Start() | Out-Null
        Pop-Location | Out-Null

        $noDir = $true
        $x = 0
        While ($noDir) {
            Get-ChildItem -Directory | ForEach-Object {
                if ($_.Name -match '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
                    $script:NodeAgentPath = Get-Item $_.FullName
                    $noDir = $false
                }
            }
            Start-Sleep -Seconds 1
            $x++
            if (($x -ge 5 -or $NodeAgentProcess.HasExited) -and $noDir) {
                Throw 'Node failed to start.'
                $noDir = $false
            }
        }
        Write-Information "Node initiated at: '$($NodeAgentPath)'"
    }
}