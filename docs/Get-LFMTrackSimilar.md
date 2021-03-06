---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMTrackSimilar.md
schema: 2.0.0
---

# Get-LFMTrackSimilar

## SYNOPSIS
Get tracks similar to another track.

## SYNTAX

### track (Default)
```
Get-LFMTrackSimilar [-Track] <String> [-Artist] <String> [-Limit <Int32>] [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMTrackSimilar -Id <Guid> [-Limit <Int32>] [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get tracks similar to other tracks.
This uses the track.getSimilar method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMTrackSimilar -Track Gore -Artist Deftones -Limit 10
```

This will get ten tracks similar to the track Gore by Deftones.

## PARAMETERS

### -Artist
Name of the artist.

```yaml
Type: String
Parameter Sets: track
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AutoCorrect
Transform misspelled artist names into correct artist names.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Musicbrainz id for the artist.

```yaml
Type: Guid
Parameter Sets: id
Aliases:

Required: True
Position: Named
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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Track
Name of the track.

```yaml
Type: String
Parameter Sets: track
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

### PowerLFM.Track.Similar
## NOTES

## RELATED LINKS
