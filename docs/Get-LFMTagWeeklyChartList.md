---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMTagWeeklyChartList.md
schema: 2.0.0
---

# Get-LFMTagWeeklyChartList

## SYNOPSIS
Get a list of available charts for this tag, expressed as date ranges which can be sent to the chart services.

## SYNTAX

```
Get-LFMTagWeeklyChartList [-Tag] <String> [<CommonParameters>]
```

## DESCRIPTION
Get a list of available charts for this tag, expressed as date ranges which can be sent to the chart services.
This uses the tag.getTagWeeklyChartList method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMTagWeeklyChartList -Tag rock
```

This gets the available charts for the tag rock as a date range.

## PARAMETERS

### -Tag
Name of the tag.
This is currently required but doesn't make a difference on the response.
Considering hard coding the value and removing this parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### PowerLFM.Tag.WeeklyChartList
## NOTES

## RELATED LINKS
