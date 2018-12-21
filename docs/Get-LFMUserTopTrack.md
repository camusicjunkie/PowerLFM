# Get-LFMUserTopTrack

## SYNOPSIS
Get the top tracks scrobbled by a user.

## SYNTAX

```
Get-LFMUserTopTrack [-UserName] <String> [[-TimePeriod] <String>] [[-Limit] <String>] [[-Page] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get the top tracks scrobbled by a user. A time period can be specified. If no time period is specified the overall chart is chosen by default. This uses the user.getTopTracks method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMUserTopTrack -UserName camusicjunkie
```

This will get the top tracks scrobbled by camusicjunkie.

### Example 2
```powershell
PS C:\> Get-LFMUserTopTrack -UserName camusicjunkie -TimePeriod 12month
```

This will get the top tracks scrobbled by camusicjunkie over the last 12 months.

## PARAMETERS

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

### -TimePeriod
Period over which to get the top artists.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Overall, 7day, 1month, 3month, 6month, 12month

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Username for the context of the request. The top tracks of this user are included in the response.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.User.TopTrack

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/user.getTopTracks](https://www.last.fm/api/show/user.getTopTracks)