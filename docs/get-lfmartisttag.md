---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Get-LFMArtistTag

## SYNOPSIS

Get the tags applied to an artist.

## SYNTAX

### artist \(Default\)

```text
Get-LFMArtistTag [-Artist] <String> [-UserName <String>] [-AutoCorrect] [<CommonParameters>]
```

### id

```text
Get-LFMArtistTag -Id <String> [-UserName <String>] [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION

Get the tags applied to an artist by an individual user. This uses the artist.getTags method from the Last.fm API.

## EXAMPLES

### Example 1

```text
PS C:\> Get-LFMArtistTag -Artist Deftones
```

This will get the tags for the artist Deftones.

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

### PowerLFM.Artist.Tag

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/artist.getTags](https://www.last.fm/api/show/artist.getTags)

