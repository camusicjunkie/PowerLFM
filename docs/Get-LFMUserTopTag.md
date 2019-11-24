---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMUserTopTag.md
schema: 2.0.0
---

# Get-LFMUserTopTag

## SYNOPSIS
Get the top tags set by a user.

## SYNTAX

```
Get-LFMUserTopTag [[-UserName] <String>] [[-Limit] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Get the top tags set by a user.
This uses the user.getTopTags method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMUserTopTag
```

This will get the top tags set by the currently authenticated user.

## PARAMETERS

### -Limit
Limit the number of results per page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Username for the context of the request.
The top tags of this user are included in the response.
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

### PowerLFM.User.TopTag
## NOTES

## RELATED LINKS
