Function Invoke-BcAction {
    [cmdletbinding(
        DefaultParameterSetName = 'folderAction',
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param (
        [ValidateScript(
            {
                if (Test-Path $_ -PathType Leaf) {
                    $_ -like '*manifest.txt'
                } elseif (Test-Path $_ -PathType Container) {
                    Test-Path $_\manifest.txt -PathType Leaf
                }
            }
        )]
        [Parameter(
            Mandatory,
            ParameterSetName = 'folderAction',
            HelpMessage = 'Path must be a manifest.txt file or a folder containing one.'
        )]
        [string]$Path,
        [Parameter(
            Mandatory,
            ParameterSetName = 'folderAction'
        )]
        [string]$UtilityPath,
        [string]$WorkingDir,
        [hashtable]$Settings,
        [switch]$PreserveWorkingDir
    )
    $ip = $InformationPreference
    $InformationPreference = 'Continue'
    $agentPath = Get-BcAgentInstallPath -AsString | Select-Object -First 1

    # If the path is a folder, append manifest.txt
    if (Test-Path $Path -PathType Container) {
        $sPath = "$path\settings.json"
        $Path = "$Path\manifest.txt"
    } else {
        $sPath = "$(Split-Path $path)\settings.json"
    }
    $splat = @{
        AgentPath  = $agentPath
        Parameters = $Settings
    }
    Join-BcSettingsHashtable @splat | ConvertTo-Json | Out-File $sPath

    # If no working dir is passed, use something in TEMP
    if ($PSBoundParameters.Key -notcontains 'WorkingDir') {
        $WorkingDir = "$($env:TEMP)\Action_$(Get-Date -UFormat %s)"
    }

    if (Test-Path $WorkingDir) {
        Write-Verbose 'The working directory already exists, clear it?'
        if ($PSCmdlet.ShouldProcess($WorkingDir, 'Remove-Item')) {
            Remove-Item $WorkingDir -Recurse -Force
        } else {
            $PSCmdlet.ShouldProcess
            return
        }
    }

    # Build Action
    $buildSplat = @{
        Path                   = 'cmd.exe'
        ArgumentList           = "/C .\runway.exe -N build -i $Path -o $($env:TEMP)\action.app"
        WorkingDirectory       = (Split-Path $UtilityPath)
        WindowStyle            = 'Hidden'
        PassThru               = $true
        RedirectStandardError  = '.\buildstderr.txt'
        RedirectStandardOutput = '.\buildstdout.txt'
    }
    Write-Verbose 'Building the action...'
    $actionProc = Start-Process @buildSplat -Wait

    # Remove settings.json
    Remove-Item $sPath -Force

    # Run Action
    $runSplat = @{
        Path                   = 'cmd.exe'
        ArgumentList           = "/C .\runner.exe run --action_zip $($env:TEMP)\action.app --path $WorkingDir"
        WorkingDirectory       = $agentPath
        WindowStyle            = 'Hidden'
        PassThru               = $true
        RedirectStandardError  = '.\runstderr.txt'
        RedirectStandardOutput = '.\runstdout.txt'
    }
    Write-Verbose 'Running the action...'
    $actionProc = Start-Process @runSplat

    # Stream std.out
    While (-not (Test-Path $WorkingDir\std.out)) {
        Start-Sleep -Seconds 1
    }
    $stream = [System.IO.File]::Open("$WorkingDir\std.out", [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    $reader = [System.IO.StreamReader]::new($stream)
    $stdOut = & {
        while ($null -ne ($line = $reader.ReadLine())) {
            $line
            Write-Information $line
        }
        while (-not $actionProc.HasExited) {
            while ($null -ne ($line = $reader.ReadLine())) {
                $line
                Write-Information $line
            }
            Start-Sleep -Seconds 1
        }
    }
    $reader.Close()

    # Collect results
    $resultPath = "$($env:TEMP)\actiontest_results.zip"
    if (Test-Path $resultPath) {
        Write-Verbose 'The results file already exists, overwrite?'
        if ($PSCmdlet.ShouldProcess($resultPath, 'Remove-Item')) {
            Remove-Item $resultPath -Recurse -Force
        }
    }
    Compress-Archive "$WorkingDir\results" -DestinationPath $resultPath

    $out = [pscustomobject]@{
        Build   = @{
            StdOut = Get-Content .\buildstdout.txt
            StdErr = Get-Content .\buildstderr.txt
        }
        Run     = @{
            StdOut = Get-Content .\runstdout.txt
            StdErr = Get-Content .\runstderr.txt
        }
        Results = Get-Item $resultPath
        StdOut  = $stdOut
    }

    # Clean up redirects
    @('buildstdout.txt', 'buildstderr.txt', 'runstdout.txt', 'runstderr.txt') | ForEach-Object {
        Remove-Item ".\$_" -ErrorAction SilentlyContinue -Force
    }

    # Clean up workingDir
    if (-not ($PreserveWorkingDir.IsPresent)) {
        Remove-Item $WorkingDir -Recurse -Force
    } else {
        $out | Add-Member -MemberType NoteProperty -Name 'WorkingDirectory' -Value Get-Item $WorkingDir
    }
    $InformationPreference = $ip
}