<#
    Code in this file will be added to the end of the .psm1. For example,
    you should set variables or other environment settings here.
#>
# Argument completer for New-BcAction
$scriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    Get-ChildItem $PSScriptRoot\templates\$wordToComplete* | Select-Object -ExpandProperty Name
}
Register-ArgumentCompleter -CommandName New-BcAction -ParameterName TemplateName -ScriptBlock $scriptBlock