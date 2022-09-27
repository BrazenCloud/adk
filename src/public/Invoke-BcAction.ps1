Function Invoke-BcAction {
    [cmdletbinding(
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
            HelpMessage = 'Path must be a manifest.txt file or a folder containing one.'
        )]
        [string]$Path,
        [string]$WorkingDirectory,
        [hashtable]$Settings,
        [switch]$PreserveWorkingDirectory,
        [switch]$IgnoreRequiredParameters,
        [switch]$SkipMissingParameters
    )
    $ip = $InformationPreference
    $InformationPreference = 'Continue'
    
    if (-not (Get-BcAdkNodeAgent).IsRunning) {
        New-BcAdkNodeAgent
    }

    $agentPath = $NodeAgentPath.FullName
    $UtilityPath = "$($NodeAgentPath.FullName)\runway.exe"

    # If the path is a folder, append manifest.txt
    if (Test-Path $Path -PathType Container) {
        $sPath = "$path\settings.json"
        $Path = "$((Resolve-Path $Path).Path)\manifest.txt"
    } else {
        $sPath = "$(Split-Path $path)\settings.json"
    }

    $parametersPath = "$(Split-Path $Path)\parameters.json"
    $parameters = Get-Content $parametersPath | ConvertFrom-Json
    if ($PSBoundParameters.Keys -notcontains 'Settings') {
        $Settings = @{}
    }

    # Build settings with empty string parameters
    if (-not $SkipMissingParameters.IsPresent) {
        if (Test-Path $parametersPath) {
            foreach ($param in $parameters) {
                if ($Settings.Keys -notcontains $param.Name) {
                    if ($param.DefaultValue.Length -gt 0) {
                        $Settings[$param.Name] = $param.DefaultValue
                    } else {
                        $Settings[$param.Name] = ''
                    }
                }
            }
        }
    }

    foreach ($key in $Settings.Keys) {
        if ($parameters.Name -notcontains $key) {
            Write-Warning "Passed parameter '$key' is not a valid parameter."
        }
    }

    $splat = @{
        AgentPath  = $agentPath
        Parameters = $Settings
    }
    Join-BcSettingsHashtable @splat | ConvertTo-Json | Out-File $sPath

    # If no working dir is passed, use something in TEMP
    $actionRun = "Action_$(Get-Date -UFormat %s)"
    if ($PSBoundParameters.Keys -notcontains 'WorkingDirectory') {
        $WorkingDirectory = "$($env:TEMP)\$actionRun"
    }

    if (Test-Path $WorkingDirectory) {
        Write-Verbose 'The working directory already exists, clear it?'
        if ($PSCmdlet.ShouldProcess($WorkingDirectory, 'Remove-Item')) {
            Remove-Item $WorkingDirectory -Recurse -Force
        } else {
            $PSCmdlet.ShouldProcess
            return
        }
    }
    New-Item $WorkingDirectory -ItemType Directory | Out-Null

    $WorkingDirectory = (Resolve-Path $WorkingDirectory).Path

    if (Test-Path "$($env:TEMP)\action.app") {
        Remove-Item "$($env:TEMP)\action.app" -Force
    }

    if (-not $IgnoreRequiredParameters.IsPresent) {
        if (Test-Path $parametersPath) {
            $parameters | Where-Object { $_.PSObject.Properties.Name -contains 'IsOptional' } | Where-Object { $_.IsOptional.ToString() -eq 'false' } | ForEach-Object {
                if ($Settings.Keys -notcontains $_.Name) {
                    Throw "Mandatory parameter: '$($_.Name)' was not provided. Pass a value via -Settings or use -IgnoreRequiredParameters"
                }
            }
        }
    }

    # Build Action
    $buildSplat = @{
        Path                   = 'cmd.exe'
        ArgumentList           = "/C .\runway.exe -N build -i $Path -o $($env:TEMP)\action.app"
        WorkingDirectory       = (Split-Path $UtilityPath)
        WindowStyle            = 'Hidden'
        PassThru               = $true
        RedirectStandardError  = "$($env:TEMP)\buildstderr_$actionRun.txt"
        RedirectStandardOutput = "$($env:TEMP)\buildstdout_$actionRun.txt"
    }
    Write-Verbose 'Building the action...'
    $actionProc = Start-Process @buildSplat -Wait

    $buildStdErr = Get-Content "$($env:TEMP)\buildstderr_$actionRun.txt"
    if ($buildStdErr.Length -gt 0) {
        Throw "Error in build: $buildStdErr"
    }

    # Remove settings.json
    Remove-Item $sPath -Force

    # Run Action
    $runSplat = @{
        Path                   = 'cmd.exe'
        ArgumentList           = "/C .\runner.exe run --action_zip $($env:TEMP)\action.app --path $WorkingDirectory"
        WorkingDirectory       = $agentPath
        WindowStyle            = 'Hidden'
        PassThru               = $true
        RedirectStandardError  = "$($env:TEMP)\runstderr_$actionRun.txt"
        RedirectStandardOutput = "$($env:TEMP)\runstdout_$actionRun.txt"
    }
    Write-Verbose 'Running the action...'
    $actionProc = Start-Process @runSplat

    # Stream std.out
    While (-not (Test-Path $WorkingDirectory\std.out)) {
        $runStdErr = Get-Content "$($env:TEMP)\runstderr_$actionRun.txt"
        if ($runStdErr.Length -gt 0) {
            Throw "Error in run: $runStdErr"
        }
        Start-Sleep -Seconds 1
    }
    Write-Verbose 'The following output is stdout from executing the action:'
    $stream = [System.IO.File]::Open("$WorkingDirectory\std.out", [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
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
            Start-Sleep -Milliseconds 100
        }
        while (-not $reader.EndOfStream) {
            while ($null -ne ($line = $reader.ReadLine())) {
                $line
                Write-Information $line
            }
            Start-Sleep -Milliseconds 100
        }
    }
    $reader.Close()

    # Collect results
    $resultPath = "$($env:TEMP)\Results_$actionRun.zip"
    if (Test-Path $resultPath) {
        Write-Verbose 'The results file already exists, overwrite?'
        if ($PSCmdlet.ShouldProcess($resultPath, 'Remove-Item')) {
            Remove-Item $resultPath -Recurse -Force
        }
    }
    if ((Get-ChildItem $WorkingDirectory\results).Count -gt 0) {
        Compress-Archive "$WorkingDirectory\results" -DestinationPath $resultPath
    } else {
        Write-Verbose 'No results to be collected.'
    }

    $global:out = [pscustomobject]@{
        Build   = @{
            StdOut = Get-Content "$($env:TEMP)\buildstdout_$actionRun.txt"
            StdErr = Get-Content "$($env:TEMP)\buildstderr_$actionRun.txt"
        }
        Run     = @{
            StdOut = Get-Content "$($env:TEMP)\runstdout_$actionRun.txt"
            StdErr = Get-Content "$($env:TEMP)\runstderr_$actionRun.txt"
        }
        Results = if (Test-Path $resultPath) { Get-Item $resultPath } else { $null }
        StdOut  = $stdOut
    }

    # Clean up redirects
    @("buildstdout_*.txt", "buildstderr_*.txt", "runstdout_*.txt", "runstderr_*.txt") | ForEach-Object {
        Remove-Item "$($env:TEMP)\$_" -ErrorAction SilentlyContinue -Force
    }

    # Clean up WorkingDirectory
    if (-not ($PreserveWorkingDirectory.IsPresent)) {
        Remove-Item $WorkingDirectory -Recurse -Force
    } else {
        $out | Add-Member -MemberType NoteProperty -Name 'WorkingDirectory' -Value (Get-Item $WorkingDirectory)
    }

    New-BcActionInvokeReport -InvocationData $out
    $out
    $InformationPreference = $ip
}