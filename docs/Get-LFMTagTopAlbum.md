---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMTagTopAlbum

## SYNOPSIS
Get the top albums tagged by this tag, ordered by tag count.

## SYNTAX

```
Get-LFMTagTopAlbum [-Tag] <String> [[-Limit] <String>] [[-Page] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the top albums tagged by this tag, ordered by tag count. This uses the tag.getTopAlbums method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMTagTopAlbum -Tag rock
```

This will get the top albums with the tag rock, ordered by tag count.

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

### -Page
Page number to return. Defaults to the first page.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.Tag.TopAlbums

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/tag.getTopAlbums](https://www.last.fm/api/show/tag.getTopAlbums)
