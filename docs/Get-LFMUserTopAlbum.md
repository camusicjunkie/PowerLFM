---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMUserTopAlbum.md
schema: 2.0.0
---

# Get-LFMUserTopAlbum

## SYNOPSIS
Get the top albums scrobbled by a user.

## SYNTAX

```
Get-LFMUserTopAlbum [[-UserName] <String>] [[-TimePeriod] <String>] [[-Limit] <Int32>] [[-Page] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
Get the top albums scrobbled by a user.
A time period can be specified.
If no time period is specified the overall chart is chosen by default.
This uses the user.getTopAlbums method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMUserTopAlbum
```

This will get the top albums scrobbled by the currently authenticated user.

### Example 2
```
PS C:\> Get-LFMUserTopAlbum -TimePeriod '1 Year'
```

This will get the top albums scrobbled by the currently authenticated user over the last year.

## PARAMETERS

### -Limit
Limit the number of results per page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimePeriod
Period over which to get the top albums.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Overall, 7 Days, 1 Month, 3 Months, 6 Months, 1 Year

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Username for the context of the request.
The top albums of this user are included in the response.
Providing no user will use the currently authenticated user.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### PowerLFM.User.TopAlbum
## NOTES

## RELATED LINKS
