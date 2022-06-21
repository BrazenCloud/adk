---
external help file: BrazenCloud.ADK-help.xml
Module Name: BrazenCloud.ADK
online version:
schema: 2.0.0
---

# Invoke-BcAction

## SYNOPSIS
Initiates an Action on a locally installed BrazenAgent.

## SYNTAX

```
Invoke-BcAction -Path <String> -UtilityPath <String> [-WorkingDir <String>] [-Settings <Hashtable>]
 [-PreserveWorkingDir] [<CommonParameters>]
```

## DESCRIPTION
Initiates a BrazenCloud Action on a locally installed BrazenAgent by building the Action, asking the BrazenAgent to run it, and then collecting the outputs and results.

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-BcAction -Path C:\path\to\action -UtilityPath C:\path\to\runway.exe -Settings @{'Output Type' = 'json'} -PreserveWorkingDir

Build            Run              Results                                                     StdOut
-----            ---              -------                                                     ------
{StdErr, StdOut} {StdErr, StdOut} C:\Users\ANTHON~1\AppData\Local\Temp\actiontest_results.zip {Get-Content: C:\Users…
```

Assuming the action folder has a manifest file in it, then this will run the action in that folder on the local BrazenAgent.

## PARAMETERS

### -Path
Path must be a manifest.txt file or a folder containing one.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreserveWorkingDir
Will preserve the Action's working directory. Useful if you would like to see additional Action output.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Settings
Pass any parameters to the action.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UtilityPath
Path to runway.exe

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkingDir
The path to use as the Action's working directory. If not specified, a temp folder is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
