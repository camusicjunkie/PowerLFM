---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMUserFriend

## SYNOPSIS
Get a list of friends for a user.

## SYNTAX

```
Get-LFMUserFriend [-UserName] <String> [[-Limit] <String>] [[-Page] <String>] [-RecentTracks]
 [<CommonParameters>]
```

## DESCRIPTION
Get a list of friends for a user. This uses the user.getFriends method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMUserFriend -UserName camusicjunkie
```

This will get the friends for camusicjunkie

### Example 2
```powershell
PS C:\> Get-LFMUserFriend -UserName camusicjunkie -RecentTracks
```

This will get the friends for camusicjunkie and their recent tracks.

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

### -RecentTracks
Show recent tracks scrobbled by user's friends.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Username for the context of the request. The friends of this user are included in the response.

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

### PowerLFM.User.Friend

## NOTES

## RELATED LINKS

https://www.last.fm/api/show/user.getFriends
