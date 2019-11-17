---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Get-LFMArtistSimilar

## SYNOPSIS
Get artists similar to another artist.

## SYNTAX

### artist (Default)
```
Get-LFMArtistSimilar [-Artist] <String> [-Limit <Int32>] [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMArtistSimilar -Id <Guid> [-Limit <Int32>] [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get artists similar to another artist. This uses the artist.getSimilar method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMArtistSimilar -Artist Deftones -Limit 10
```

This will get ten artists similar to the Deftones.

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
Type: Guid
Parameter Sets: id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Limit
Limit the number of similar artists.

```yaml
Type: Int32
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

### PowerLFM.Artist.Similar

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/artist.getSimilar](https://www.last.fm/api/show/artist.getSimilar)
