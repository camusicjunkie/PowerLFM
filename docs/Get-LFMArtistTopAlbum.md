---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMArtistTopAlbum

## SYNOPSIS
Get the top albums for an artist.

## SYNTAX

### artist (Default)
```
Get-LFMArtistTopAlbum -Artist <String> [-Limit <String>] [-Page <String>] [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMArtistTopAlbum -Id <String> [-Limit <String>] [-Page <String>] [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get the top albums for an artist, ordered by popularity. This uses the artist.getTopAlbums method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMArtistTopAlbum -Artist Deftones
```

This will get the top Deftones albums, ordered by popularity.

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

### PowerLFM.Artist.TopAlbum

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/artist.getTopAlbums](https://www.last.fm/api/show/artist.getTopAlbums)
