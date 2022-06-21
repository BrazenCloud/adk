---
external help file: BrazenCloud.ADK-help.xml
Module Name: BrazenCloud.ADK
online version:
schema: 2.0.0
---

# Get-BcAgentInstallPath

## SYNOPSIS
Returns the install path for the BrazenCloud BrazenAgent. Defaults to the first installed agent if there are multiple.

## SYNTAX

### dirInfo (Default)
```
Get-BcAgentInstallPath [<CommonParameters>]
```

### str
```
Get-BcAgentInstallPath [-AsString] [<CommonParameters>]
```

## DESCRIPTION
Looks in 'C:\Program Files\Runway' for subfolders and the first one is returned. This is the installation location for the BrazenCloud BrazenAgent.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-BcAgentInstallPath
```

Returns the first installed BrazenAgent as a DirectoryInfo object

### Example 2
```powershell
PS C:\> Get-BcAgentInstallPath -AsString
```

Returns the first installed BrazenAgent as path string

## PARAMETERS

### -AsString
Sets the output to be the path as a string.

```yaml
Type: SwitchParameter
Parameter Sets: str
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

### System.IO.DirectoryInfo

### System.String

## NOTES

## RELATED LINKS
