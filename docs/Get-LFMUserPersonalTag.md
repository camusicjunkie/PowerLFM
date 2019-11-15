---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMUserPersonalTag

## SYNOPSIS
Get a list of personal tags for a user.

## SYNTAX

```
Get-LFMUserPersonalTag [-Tag] <String> [-TagType] <String> [[-UserName] <String>] [[-Limit] <Int32>]
 [[-Page] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Get a list of personal tags for a user. This uses the user.getPersonalTags method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMUserPersonalTag -Tag Heavy -TagType Artist
```

This will get the user's personal tag heavy with a tag type of artist.

## PARAMETERS

### -Limit
Limit the number of results per page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Page
Page number to return. Defaults to the first page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Name of the tag.

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

### -TagType
Type of the tagged item.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Artist, Album, Track

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserName
Username for the context of the request. The personal tags of this user are included in the response. Providing no user will use the currently authenticated user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.User.PersonalTag

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/user.getPersonalTags](https://www.last.fm/api/show/user.getPersonalTags)
