---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: null
schema: 2.0.0
---

# Remove-LFMConfiguration

## SYNOPSIS

Removes the current configuration.

## SYNTAX

```text
Remove-LFMConfiguration [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Removes the configuration from the Windows credential manager. This will remove the ApiKey, SharedSecret, and SessionKey from the current session.

## EXAMPLES

### Example 1

```text
PS C:\> Remove-LFMConfiguration
```

This will remove the current configuration.

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

