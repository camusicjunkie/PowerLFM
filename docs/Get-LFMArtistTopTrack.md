# Get-LFMArtistTopTrack

## SYNOPSIS
Get the top tracks for an artist.

## SYNTAX

### artist (Default)
```
Get-LFMArtistTopTrack -Artist <String> [-Limit <String>] [-Page <String>] [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMArtistTopTrack -Id <String> [-Limit <String>] [-Page <String>] [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get the top tracks for an artist, ordered by popularity. This uses the artist.getTopTracks method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMArtistTopTrack -Artist Deftones
```

This will get the top Deftones tracks, ordered by popularity.

## PARAMETERS

### -Artist
Name of the artist.

```yaml
Type: String
Parameter Sets: artist
Aliases:

Required: True
Position: Named
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

### -Limit
Limit the number of results per page.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.Artist.TopTrack

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/artist.getTopTracks](https://www.last.fm/api/show/artist.getTopTracks)
