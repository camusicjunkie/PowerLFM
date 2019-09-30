---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Get-LFMArtistTopTag

## SYNOPSIS
Get the top tags for an artist.

## SYNTAX

### artist (Default)
```
Get-LFMArtistTopTag [-Artist] <String> [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMArtistTopTag -Id <String> [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get the top tags for an artist, ordered by popularity. This uses the artist.getTopTags method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMArtistTopTag -Artist Deftones
```

This will get the top Deftones tags, ordered by popularity.

## PARAMETERS

### -Artist
Name of the artist.

```yaml
Type: String
Parameter Sets: artist
Aliases:

Required: True
Position: 0
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.Artist.Tag

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/album.getTopTags](https://www.last.fm/api/show/album.getTopTags)
