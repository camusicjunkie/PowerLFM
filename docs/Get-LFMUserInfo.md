---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMUserInfo.md
schema: 2.0.0
---

# Get-LFMUserInfo

## SYNOPSIS
Get information about a user.

## SYNTAX

```
Get-LFMUserInfo [[-UserName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get information about a user.
This uses the user.getInfo method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMUserInfo
```

This will get the user information for the currently authenticated user.

## PARAMETERS

### -UserName
Username for the context of the request.
The information for this user is included in the response.
Providing no user will use the currently authenticated user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### PowerLFM.User.Info
## NOTES

## RELATED LINKS
