---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Get-LFMUserWeeklyChartList

## SYNOPSIS

Get a list of available charts for a user.

## SYNTAX

```text
Get-LFMUserWeeklyChartList [[-UserName] <String>] [<CommonParameters>]
```

## DESCRIPTION

Get a list of available charts for a user. These charts are expressed as date ranges that can be sent to the other chart services. This uses the user.getWeeklyChartList method from the Last.fm API.

## EXAMPLES

### Example 1

```text
PS C:\> Get-LFMUserWeeklyChartList -UserName camusicjunkie
```

This will get the chart lists for camusicjunkie.

## PARAMETERS

### -UserName

Username for the context of the request. The chart list of this user is included in the response. Providing no user will use the currently authenticated user. The API docs say the user field is mandatory but testing shows that it isn't actually required. Will keep implemented for now.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.User.WeeklyChartList

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/user.getWeeklyChartList](https://www.last.fm/api/show/user.getWeeklyChartList)

