---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Get-LFMGeoTopTrack

## SYNOPSIS

Get the most popular tracks by country and city.

## SYNTAX

```text
Get-LFMGeoTopTrack [-Country] <String> [[-City] <String>] [[-Limit] <String>] [[-Page] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Get the most popular tracks by country and city. This uses the geo.getTopTracks method from the Last.fm API.

## EXAMPLES

### Example 1

```text
PS C:\> Get-LFMGeoTopTrack -Country Netherlands -City Amsterdam
```

This will get the top tracks in Amsterdam.

## PARAMETERS

### -City

Name of the city. This must be within the country specified.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

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
Position: 2
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
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.Geo.TopTracks

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/geo.getTopTracks](https://www.last.fm/api/show/geo.getTopTracks)

