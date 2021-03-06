---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMChartTopArtist.md
schema: 2.0.0
---

# Get-LFMChartTopArtist

## SYNOPSIS
Get the top artists chart.

## SYNTAX

```
Get-LFMChartTopArtist [[-Limit] <Int32>] [[-Page] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Get the top artists chart.
This uses the chart.getTopArtists method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMChartTopArtist
```

This will get the top artists chart.

## PARAMETERS

### -Limit
Limit the number of results per page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Page
Page number to return.
Defaults to the first page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### PowerLFM.Chart.TopArtists
## NOTES

## RELATED LINKS
