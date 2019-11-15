---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMTrackTag

## SYNOPSIS
Get the tags applied to a track.

## SYNTAX

### track (Default)
```
Get-LFMTrackTag [-Track] <String> [-Artist] <String> [-UserName <String>] [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMTrackTag -Id <Guid> [-UserName <String>] [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get the tags applied to a track by an individual user. This uses the track.getTags method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMTrackTag -Track Gore -Artist Deftones
```

This will get tags for the track Gore by Deftones

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
Musicbrainz id for the album.

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

### -UserName
Username for the context of the request. The user tags for this track are included in the response. Providing no user will use the currently authenticated user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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

## OUTPUTS

### PowerLFM.Track.UserTag

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/track.getTags](https://www.last.fm/api/show/track.getTags)
