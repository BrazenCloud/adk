Function Invoke-BcAction {
    [cmdletbinding(
        DefaultParameterSetName = 'folderAction'
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
        [string]$WorkingDir
    )
    $agentPath = Get-BcAgentInstallPath -AsString | Select-Object -First 1

    # If the path is a folder, append manifest.txt
    if (Test-Path $Path -PathType Container) {
        $Path = "$Path\manifest.txt"
    }

    # If no working dir is passed, use something in TEMP
    if ($PSBoundParameters.Key -notcontains 'WorkingDir') {
        $WorkingDir = "$($env:TEMP)\actiontest"
    }

    if (Test-Path $WorkingDir) {
        Remove-Item $WorkingDir -Recurse -Force
    }
    
    # Build Action
    Invoke-Command -ScriptBlock ([scriptblock]::Create("$UtilityPath -N build -i $Path -o $($env:TEMP)\action.app") )

    # Run Action
    $actionProc = Start-Process cmd.exe -ArgumentList "/C .\runner.exe run --action_zip $($env:TEMP)\action.app --path $WorkingDir" -WorkingDirectory $agentPath -WindowStyle Hidden -PassThru -RedirectStandardError .\stderr.txt -RedirectStandardOutput stdout.txt

    # Stream std.out
    While (-not (Test-Path $WorkingDir\std.out)) {
        Start-Sleep -Seconds 1
    }
    $stream = [System.IO.File]::Open("$WorkingDir\std.out", [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    $reader = [System.IO.StreamReader]::new($stream)
    while ($null -ne ($line = $reader.ReadLine())) {
        $line
    }
    while (-not $actionProc.HasExited) {
        while ($null -ne ($line = $reader.ReadLine())) {
            $line
        }
        Start-Sleep -Seconds 1
    }
    $reader.Close()
}