---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMTrackTopTag

## SYNOPSIS
Get the top tags for a track.

## SYNTAX

### track (Default)
```
Get-LFMTrackTopTag [-Track] <String> [-Artist] <String> [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMTrackTopTag -Id <String> [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get the top tags for a track, ordered by tag count. This uses the track.getTopTags method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMTrackTopTag -Track Gore -Artist Deftones
```

This will get the top tags for the track Gore by Deftones.

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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Musicbrainz id for the artist.

```yaml
Type: String
Parameter Sets: id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### PowerLFM.Track.TopTag

## NOTES

## RELATED LINKS
