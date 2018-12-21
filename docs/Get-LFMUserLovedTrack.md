# Get-LFMUserLovedTrack

## SYNOPSIS
Get the tracks loved by a user.

## SYNTAX

```
Get-LFMUserLovedTrack [-UserName] <String> [[-Limit] <String>] [[-Page] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the tracks loved by a user. This uses the user.getLovedTracks method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMUserLovedTrack -UserName camusicjunkie
```

This will get all the loved tracks for camusicjunkie.

## PARAMETERS

### -Limit
Limit the number of results per page.

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

### -Page
Page number to return. Defaults to the first page.

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

### -UserName
Username for the context of the request. The loved tracks of this user are included in the response.

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

### PowerLFM.User.LovedTrack

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/user.getLovedTracks](https://www.last.fm/api/show/user.getLovedTracks)