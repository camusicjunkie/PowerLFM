---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMUserArtistTrack

## SYNOPSIS
Get a list of tracks by a given artist scrobbled by a user.

## SYNTAX

```
Get-LFMUserArtistTrack -UserName <String> -Artist <String> [-StartDate <DateTime>] [-EndDate <DateTime>]
 [-Page <String>] [<CommonParameters>]
```

## DESCRIPTION
Get a list of tracks by a given artist scrobbled by a user. Include time ranges to limit tracks to those dates. This uses the user.getArtistTracks method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMUserArtistTrack -UserName camusicjunkie -Artist Deftones
```

This will get all Deftones tracks scrobbled by camusicjunkie.

### Example 2
```powershell
PS C:\> Get-LFMUserArtistTrack -UserName camusicjunkie -Artist Deftones -StartDate 1/1/2018 -EndDate 6/30/2018
```

This will get all Deftones tracks scrobbled by camusicjunkie between the given dates. If no tracks were scrobbled during these dates this will return null.

## PARAMETERS

### -Artist
Name of the artist.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EndDate
Date to end the search.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartDate
Date to start the search.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Username for the context of the request. The tracks scrobbled by this user are included in the response.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.User.ArtistTrack

## NOTES

## RELATED LINKS

https://www.last.fm/api/show/user.getArtistTracks
