---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Set-LFMTrackScrobble.md
schema: 2.0.0
---

# Set-LFMTrackScrobble

## SYNOPSIS
Add a track play to the profile of the currently authenticated user.

## SYNTAX

```
Set-LFMTrackScrobble [-Artist] <String> [-Track] <String> [-Timestamp] <DateTime> [[-Album] <String>]
 [[-Id] <Guid>] [[-TrackNumber] <Int32>] [[-Duration] <Int32>] [-PassThru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Add a track play to the profile of the currently authenticated user.
This uses the track.scrobble method from the Last.fm API.

If Last.fm cannot be reached at all, the play is added to the scrobble queue instead of
being lost, and a warning says so.
Queued plays survive restarts.
Use `-WarningAction Stop` in a script that needs an unreachable Last.fm to be fatal.

Only an unreachable Last.fm queues.
Anything Last.fm answered - a rejected api key, a filtered artist, an outage returning 503 -
throws as it always has.

Every call attempts to flush the queue before scrobbling, so the queue empties as soon as
Last.fm can be reached again.
Use `Get-LFMScrobbleQueue`, `Send-LFMScrobbleQueue` and `Clear-LFMScrobbleQueue` to work
with the queue directly.

## EXAMPLES

### Example 1
```
PS C:\> Set-LFMTrackScrobble -Artist Deftones -Track Gore
```

This will scrobble the track Gore by Deftones for the currently authenticated user.

### Example 2
```
PS C:\> Set-LFMTrackScrobble -Artist Deftones -Track Gore -Timestamp (Get-Date) -Album Gore -TrackNumber 9 -Duration 299
```

This will scrobble the track Gore by Deftones with more granular information.
This is updated for the currently authenticated user.

## PARAMETERS

### -Album
Name of the album.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

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

### -Duration
Length of the track in seconds.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassThru
Returns an object with info on the track set to scrobble.
A queued play returns a `PowerLFM.Track.PendingScrobble` instead.

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

### -Timestamp
Time the track started playing.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Track
Name of the track.

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

### -TrackNumber
Number of the track on the album.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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

### System.DateTime

### System.Guid

### System.Int32

## OUTPUTS

### PowerLFM.Track.Scrobble

### PowerLFM.Track.PendingScrobble

## NOTES

## RELATED LINKS

[Get-LFMScrobbleQueue](Get-LFMScrobbleQueue.md)

[Send-LFMScrobbleQueue](Send-LFMScrobbleQueue.md)

[Clear-LFMScrobbleQueue](Clear-LFMScrobbleQueue.md)
