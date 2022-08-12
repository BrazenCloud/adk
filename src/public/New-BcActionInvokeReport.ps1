Function New-BcActionInvokeReport {
    [cmdletbinding()]
    param (
        [psobject]$InvocationData
    )

    $str = @'
-------------------------------------------------------------
 ____                           ____ _                 _ 
| __ ) _ __ __ _ _______ _ __  / ___| | ___  _   _  __| |
|  _ \| '__/ _` |_  / _ \ '_ \| |   | |/ _ \| | | |/ _` |
| |_) | | | (_| |/ /  __/ | | | |___| | (_) | |_| | (_| |
|____/|_|  \__,_/___\___|_| |_|\____|_|\___/ \__,_|\__,_|
-------------------------------------------------------------
 Action Invocation Report
-------------------------------------------------------------
'@

    Write-Host $str


    Write-Host "Build Process:  " -NoNewline
    If ($InvocationData.Build.StdErr.Length -gt 0) {
        Write-Host "Errors. View with: '$Out.Build.StdErr'" -ForegroundColor Red
    } else {
        Write-Host "No Errors" -ForegroundColor Green
    }

    Write-Host "Run Process:    " -NoNewline
    If ($InvocationData.Build.StdErr.Length -gt 0) {
        Write-Host "Errors. View with: '$Out.Run.StdErr'" -ForegroundColor Red
    } else {
        Write-Host "No Errors" -ForegroundColor Green
    }

    Write-Host "Action Output:  " -NoNewline
    Write-Host "$($InvocationData.StdOut.Count) lines of stdout. View with '`$Out.StdOut'" -ForegroundColor Green

    Write-Host "Results:        " -NoNewline
    If ($InvocationData.Results.Length -gt 0) {
        Write-Host $InvocationData.Results -ForegroundColor Green
    } else {
        Write-Host "No results." -ForegroundColor Yellow
    }
}