---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Search-LFMArtist

## SYNOPSIS
Search for an artist by name.

## SYNTAX

```
Search-LFMArtist [-Artist] <String> [[-Limit] <String>] [[-Page] <String>] [<CommonParameters>]
```

## DESCRIPTION
Search for an artist by name. The results will be sorted by relevance. This uses the artist.search method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Search-LFMArtist -Artist Deftones
```

This will search for artists that match Deftones.

## PARAMETERS

### -Artist
Name of the artist.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.Artist.Search

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/artist.search](https://www.last.fm/api/show/artist.search)
