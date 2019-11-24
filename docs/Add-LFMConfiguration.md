---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Add-LFMConfiguration.md
schema: 2.0.0
---

# Add-LFMConfiguration

## SYNOPSIS
Adds the token and keys to the credential manager.

## SYNTAX

```
Add-LFMConfiguration [-ApiKey] <String> [-SessionKey] <String> [-SharedSecret] <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Takes the API key and shared secret received from Last.fm and adds them to the credential manager.
This will also add the session key after it has been requested.

## EXAMPLES

### Example 1
```
PS C:\> $session = Request-LFMToken -ApiKey $ApiKey -SharedSecret $SharedSecret | Request-LFMSession
PS C:\> $session | Add-LFMConfiguration
```

This will take the session key requested from Last.fm and add it to the $session variable.
The $session will then be added to the credential manager.

### Example 2
```
PS C:\> Request-LFMToken -ApiKey $ApiKey -SharedSecret $SharedSecret | Request-LFMSession | Add-LFMConfiguration
```

This will take the session key requested from Last.fm and add it to the credential manager using a single piped command.

## PARAMETERS

### -ApiKey
API key that was created on Last.fm for a user and application.
This is required for all API calls.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SessionKey
Session key that was created on Last.fm for a user and application.
This is required for all authenticated API calls.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SharedSecret
Shared secret that was created on Last.fm for a user and application.
This is required for API calls that need to be signed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
