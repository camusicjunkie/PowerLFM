---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Set-LFMTrackNowPlaying.md
schema: 2.0.0
---

# Set-LFMTrackNowPlaying

## SYNOPSIS
Notify Last.fm that a user has started listening to a track.

## SYNTAX

```
Set-LFMTrackNowPlaying [-Track] <String> [-Artist] <String> [[-Album] <String>] [[-Id] <Guid>]
 [[-Duration] <Int32>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Notify Last.fm that a user has started listening to a track.
This uses the track.updateNowPlaying method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Set-LFMTrackNowPlaying -Track Gore -Artist Deftones
```

This will set the track Gore by Deftones as now playing for the currently authenticated user.

### Example 2
```
PS C:\> Set-LFMTrackNowPlaying -Track Passenger -Artist Deftones -Album 'White Pony' -Duration 367 -Id '119c683c-d078-41f3-b63c-cb92816d7329'
```

This will set the track Passenger by Deftones as now playing with more granular information.
This is updated for the currently authenticated user.

## PARAMETERS

### -Album
Name of the album.

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

### -Artist
Name of the artist

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

### -Duration
Length of the track in seconds.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Id
Musicbrainz id for the track.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassThru
Returns an object with info on the track set to now playing.

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

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Guid

### System.Int32

## OUTPUTS

### PowerLFM.Track.NowPlaying

## NOTES

## RELATED LINKS
