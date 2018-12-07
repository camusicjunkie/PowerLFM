---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMUserWeeklyAlbumChart

## SYNOPSIS
Get an album chart for a user.

## SYNTAX

```
Get-LFMUserWeeklyAlbumChart [-UserName] <String> [[-StartDate] <String>] [[-EndDate] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get an album chart for a user. A date range can be specified. If no date range is specified the most recent album chart is chosen by default. This uses the user.getWeeklyAlbumChart method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMUserWeeklyAlbumChart -UserName camusicjunkie
```

This will get the recent album chart for camusicjunkie.

### Example 2
```powershell
PS C:\> Get-LFMUserWeeklyAlbumChart -UserName camusicjunkie -StartDate 11/1/2018 -EndDate 12/1/2018
```

This will get the album chart for camusicjunkie within the specified date range.

### Example 3
```powershell
PS C:\> (Get-LFMUserWeeklyChartList -UserName camusicjunkie)[0] | Get-LFMUserWeeklyAlbumChart
```

This will get the first chart list for camusicjunkie and send it down the pipeline to get the album chart.

## PARAMETERS

### -EndDate
Date to end the range.

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

### -StartDate
Date to start the range.

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

### -UserName
Username for the context of the request. The album chart of this user is included in the response.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.User.WeeklyAlbumChart

## NOTES

## RELATED LINKS

https://www.last.fm/api/show/user.getWeeklyAlbumChart
