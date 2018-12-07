---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMArtistInfo

## SYNOPSIS
Get the metadata and biography for an artist.

## SYNTAX

### artist (Default)
```
Get-LFMArtistInfo -Artist <String> [-UserName <String>] [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMArtistInfo -Id <String> [-UserName <String>] [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get the metadata and biography for an artist using the artist name or a musicbrainz id. This uses the artist.getInfo method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMArtistInfo -Artist Deftones
```

Get info for the artist Deftones.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.Artist.Info

## NOTES

## RELATED LINKS

https://www.last.fm/api/show/artist.getInfo
