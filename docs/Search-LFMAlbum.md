---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Search-LFMAlbum.md
schema: 2.0.0
---

# Search-LFMAlbum

## SYNOPSIS
Search for an album by name.

## SYNTAX

```
Search-LFMAlbum [-Album] <String> [[-Limit] <Int32>] [[-Page] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Search for an album by name.
The results will be sorted by relevance.
This uses the album.search method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Search-LFMAlbum -Album Gore
```

This will search for albums that match Gore.

## PARAMETERS

### -Album
Name of the album.

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

### -Page
Page number to return.
Defaults to the first page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### PowerLFM.Album.Search
## NOTES

## RELATED LINKS
