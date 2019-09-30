---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Get-LFMGeoTopArtist

## SYNOPSIS
Get the most popular artists by country.

## SYNTAX

```
Get-LFMGeoTopArtist [-Country] <String> [[-Limit] <String>] [[-Page] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the most popular artists by country. This uses the geo.getTopArtists method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMGeoTopArtist -Country Netherlands
```

This will get the top artists in the Netherlands.

## PARAMETERS

### -Country
Name of the country as defined by the ISO 3166-1 standard.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Limit
Limit the number of results per page.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.Geo.TopArtists

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/geo.getTopArtists](https://www.last.fm/api/show/geo.getTopArtists)
