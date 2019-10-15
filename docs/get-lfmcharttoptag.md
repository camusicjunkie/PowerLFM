---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Get-LFMChartTopTag

## SYNOPSIS

Get the top tags chart.

## SYNTAX

```text
Get-LFMChartTopTag [[-Limit] <String>] [[-Page] <String>] [<CommonParameters>]
```

## DESCRIPTION

Get the top tags chart. This uses the chart.getTopTags method from the Last.fm API.

## EXAMPLES

### Example 1

```text
PS C:\> Get-LFMChartTopTag
```

This will get the top tags chart.

## PARAMETERS

### -Limit

Limit the number of results per page.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### PowerLFM.Chart.TopTags

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/chart.getTopTags](https://www.last.fm/api/show/chart.getTopTags)

