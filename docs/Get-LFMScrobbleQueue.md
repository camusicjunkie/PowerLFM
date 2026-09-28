---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMScrobbleQueue.md
schema: 2.0.0
---

# Get-LFMScrobbleQueue

## SYNOPSIS
Get the pending scrobbles waiting in the scrobble queue.

## SYNTAX

```
Get-LFMScrobbleQueue [<CommonParameters>]
```

## DESCRIPTION
Get the pending scrobbles waiting in the scrobble queue.
A pending scrobble is a play `Set-LFMTrackScrobble` captured locally because Last.fm could
not be reached, and until it is submitted the local record is the only one that exists.

Nothing is sent to Last.fm and no configuration is needed to read the queue.
The `MatchesConfiguration` property reports whether a pending scrobble was captured under
the session key in the loaded configuration, which is what decides whether
`Send-LFMScrobbleQueue` will submit it.
Without a configuration loaded, nothing matches.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMScrobbleQueue
```

This will return every pending scrobble in the queue.

### Example 2
```
PS C:\> Get-LFMScrobbleQueue | Where-Object { -not $_.MatchesConfiguration }
```

This will return the pending scrobbles the loaded configuration cannot submit.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### PowerLFM.Track.PendingScrobble

## NOTES

## RELATED LINKS

[Send-LFMScrobbleQueue](Send-LFMScrobbleQueue.md)

[Clear-LFMScrobbleQueue](Clear-LFMScrobbleQueue.md)

[Set-LFMTrackScrobble](Set-LFMTrackScrobble.md)
