---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMTrackCorrection.md
schema: 2.0.0
---

# Get-LFMTrackCorrection

## SYNOPSIS
Gets the supplied track and sees if there is a correction to a canonical track.

## SYNTAX

```
Get-LFMTrackCorrection [-Track] <String> [-Artist] <String> [<CommonParameters>]
```

## DESCRIPTION
Gets the supplied track and sees if there is a correction to a canonical track.
The results can be pretty inconsistent.
This is best used on tracks or artists when trying to correct a name with punctuation or accents.
This uses the track.getCorrection method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMTrackCorrection -Track Joga -Artist Bjork
```

This will correct both the track and artist to their correct names as they both should include accents.

## PARAMETERS

### -Artist
Name of the artist that needs to be corrected.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Track
Name of the track that needs to be corrected.

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

### PowerLFM.Track.Correction
## NOTES

## RELATED LINKS
