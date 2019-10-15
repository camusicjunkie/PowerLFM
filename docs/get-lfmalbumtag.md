---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Get-LFMAlbumTag

## SYNOPSIS

Get the tags applied to an album.

## SYNTAX

### album \(Default\)

```text
Get-LFMAlbumTag [-Album] <String> [-Artist] <String> [-UserName <String>] [-AutoCorrect] [<CommonParameters>]
```

### id

```text
Get-LFMAlbumTag -Id <String> [-UserName <String>] [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION

Get the tags applied to an album by an individual user. This uses the album.getTags method from the Last.fm API.

## EXAMPLES

### Example 1

```text
PS C:\> Get-LFMAlbumTag -Album Gore -Artist Deftones
```

This will get tags for the album Gore by Deftones

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
Type: String
Parameter Sets: id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserName

Username for the context of the request. The user tags for this album are included in the response. Providing no user will use the currently authenticated user.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.Album.Tag

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/album.getTags](https://www.last.fm/api/show/album.getTags)

