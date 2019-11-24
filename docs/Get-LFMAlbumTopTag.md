---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMAlbumTopTag.md
schema: 2.0.0
---

# Get-LFMAlbumTopTag

## SYNOPSIS
Get the top tags for an album.

## SYNTAX

### album (Default)
```
Get-LFMAlbumTopTag [-Album] <String> [-Artist] <String> [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMAlbumTopTag -Id <Guid> [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get the top tags for an album, ordered by popularity.
This uses the album.getTopTags method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMAlbumTopTag -Album Gore -Artist Deftones
```

This will get the top tags for the album Gore by Deftones

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
Default value: False
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### PowerLFM.Album.Tag
## NOTES

## RELATED LINKS
