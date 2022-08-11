Function New-BcActionInvokeReport {
    [cmdletbinding()]
    param (
        [psobject]$InvocationData
    )

    Write-Host "--------------------------------"
    Write-Host "---Action Invocation Complete---"
    Write-Host "--------------------------------"

    Write-Host "Build Process: " -NoNewline
    If ($InvocationData.Build.StdErr.Length -gt 0) {
        Write-Host "Build Errors:" -ForegroundColor Red
        Write-Host ($InvocationData.Build.StdErr -join "`n")
    } else {
        Write-Host "No Errors" -ForegroundColor Green
    }

    Write-Host "Run Process: " -NoNewline
    If ($InvocationData.Build.StdErr.Length -gt 0) {
        Write-Host "Run Errors:" -ForegroundColor Red
        Write-Host ($InvocationData.Run.StdErr -join "`n") -ForegroundColor Red
    } else {
        Write-Host "No Errors" -ForegroundColor Green
    }

    Write-Host "Action Output: " -NoNewline
    Write-Host "$($InvocationData.StdOut.Count) lines of stdout." -ForegroundColor Green

    Write-Host "Results: " -NoNewline
    If ($InvocationData.Results.Length -gt 0) {
        Write-Host $InvocationData.Results
    } else {
        Write-Host "No results."
    }
}