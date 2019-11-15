---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Get-LFMAlbumInfo

## SYNOPSIS
Get the metadata and tracklist for an album.

## SYNTAX

### album (Default)
```
Get-LFMAlbumInfo [-Album] <String> [-Artist] <String> [-UserName <String>] [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMAlbumInfo -Id <Guid> [-UserName <String>] [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get the metadata and tracklist for an album using the album name or a musicbrainz id. This uses the album.getInfo method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMAlbumInfo -Artist Deftones -Album Gore
```

This will get info for the album Gore by Deftones

## PARAMETERS

### -Album
Name of the album.

```yaml
Type: String
Parameter Sets: album
Aliases:

Required: True
Position: 0
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

### -UserName
Username for the context of the request. If used, the user's playcount for this album is included in the response.

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

### PowerLFM.Album.Info

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/album.getInfo](https://www.last.fm/api/show/album.getInfo)
