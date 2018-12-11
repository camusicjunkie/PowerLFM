# Get-LFMAlbumTopTag

## SYNOPSIS
Get the top tags for an album.

## SYNTAX

### album (Default)
```
Get-LFMAlbumTopTag -Album <String> -Artist <String> [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMAlbumTopTag -Id <String> [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get the top tags for an album, ordered by popularity. This uses the album.getTopTags method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMAlbumTopTag -Album Gore -Artist Deftones
```

This will get top tags for the album Gore by Deftones

## PARAMETERS

### -Album
Name of the album.

```yaml
Type: String
Parameter Sets: album
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Artist
Name of the artist.

```yaml
Type: String
Parameter Sets: album
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
Musicbrainz id for the album.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.Album.TopTag

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/album.getTopTags](https://www.last.fm/api/show/album.getTopTags)
