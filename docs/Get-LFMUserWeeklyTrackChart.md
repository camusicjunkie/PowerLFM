---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMUserWeeklyTrackChart.md
schema: 2.0.0
---

# Get-LFMUserWeeklyTrackChart

## SYNOPSIS
Get a track chart for a user.

## SYNTAX

```
Get-LFMUserWeeklyTrackChart [[-StartDate] <DateTime>] [[-EndDate] <DateTime>] [[-UserName] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get a track chart for a user.
A date range can be specified.
If no date range is specified the most recent track chart is chosen by default.
This uses the user.getWeeklyTrackChart method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMUserWeeklyTrackChart
```

This will get the recent track chart for the currently authenticated user.

### Example 2
```
PS C:\> Get-LFMUserWeeklyTrackChart -StartDate 11/1/2018 -EndDate 12/1/2018
```

This will get the track chart for the currently authenticated user within the specified date range.

### Example 3
```
PS C:\> (Get-LFMUserWeeklyChartList)[0] | Get-LFMUserWeeklyTrackChart
```

This will get the first chart list for the currently authenticated user and send it down the pipeline to get the track chart.

## PARAMETERS

### -EndDate
Date to end the range.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -StartDate
Date to start the range.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserName
Username for the context of the request.
The track chart of this user is included in the response.
Providing no user will use the currently authenticated user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### PowerLFM.User.WeeklyTrackChart
## NOTES

## RELATED LINKS
