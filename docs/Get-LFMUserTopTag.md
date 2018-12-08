---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMUserTopTag

## SYNOPSIS
Get the top tags set by a user.

## SYNTAX

```
Get-LFMUserTopTag [-UserName] <String> [[-Limit] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the top tags set by a user. This uses the user.getTopTags method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMUserTopTag -UserName camusicjunkie
```

This will get the top tags set by camusicjunkie.

## PARAMETERS

### -Limit
Limit the number of results per page.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Username for the context of the request. The top tags of this user are included in the response.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.User.TopTag

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/user.getTopTags](https://www.last.fm/api/show/user.getTopTags)
