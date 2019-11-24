---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMUserTrackScrobble.md
schema: 2.0.0
---

# Get-LFMUserTrackScrobble

## SYNOPSIS
Get all the times a track has been scrobbled by a user.

## SYNTAX

```
Get-LFMUserTrackScrobble [-Track] <String> [-Artist] <String> [[-UserName] <String>] [[-Limit] <Int32>]
 [[-Page] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Get all the times a track has been scrobbled by a user.
This uses the user.getTrackScrobbles method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMUserTrackScrobble -Track Gore -Artist Deftones
```

This will get all the times the track Gore by Deftones has been scrobbled by the currently authenticated user.

## PARAMETERS

### -Artist
Name of the artist.

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

### -Limit
Limit the number of results per page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
Position: 4
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

### -UserName
Username for the context of the request.
The scrobbled tracks of this user are included in the response.
Providing no user will use the currently authenticated user.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### PowerLFM.User.TrackScrobble
## NOTES

## RELATED LINKS
