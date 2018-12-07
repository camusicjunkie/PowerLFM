---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMUserWeeklyChartList

## SYNOPSIS
Get a list of available charts for a user.

## SYNTAX

```
Get-LFMUserWeeklyChartList [-UserName] <String> [<CommonParameters>]
```

## DESCRIPTION
Get a list of available charts for a user. These charts are expressed as date ranges that can be sent to the other chart services. This uses the user.getWeeklyChartList method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMUserWeeklyChartList -UserName camusicjunkie
```

This will get the chart lists for camusicjunkie.

## PARAMETERS

### -UserName
Username for the context of the request. The chart list of this user is included in the response.

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

### PowerLFM.User.WeeklyChartList

## NOTES

## RELATED LINKS

https://www.last.fm/api/show/user.getWeeklyChartList
