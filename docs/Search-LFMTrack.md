---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Search-LFMTrack

## SYNOPSIS
Search for a track by name.

## SYNTAX

```
Search-LFMTrack [-Track] <String> [[-Limit] <Int32>] [[-Page] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Search for a track by name. The results will be sorted by relevance. This uses the track.search method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Search-LFMTrack -Track 'White Pony'
```

This will search for tracks that match White Pony.

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

### -Page
Page number to return. Defaults to the first page.

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

### -Track
Name of the track.

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

### PowerLFM.Track.Search

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/track.search](https://www.last.fm/api/show/track.search)
