---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Send-LFMScrobbleQueue.md
schema: 2.0.0
---

# Send-LFMScrobbleQueue

## SYNOPSIS
Submit the pending scrobbles waiting in the scrobble queue.

## SYNTAX

```
Send-LFMScrobbleQueue [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Submit the pending scrobbles waiting in the scrobble queue.
A pending scrobble is a play `Set-LFMTrackScrobble` captured locally because Last.fm could
not be reached.
This uses the track.scrobble method from the Last.fm API, fifty pending scrobbles per call.

`Set-LFMTrackScrobble` attempts a flush of its own before every submission, so the queue
normally flushes on its own.
Run this command to flush it without scrobbling something new.

Only the pending scrobbles captured under the session key in the loaded configuration are
submitted.
Any others stay queued and are reported with a warning, so a queue filled under one account
is never written to another account's listening history.

A pending scrobble Last.fm accepts over the wire and then declines to record because its
timestamp is older than Last.fm will take can never succeed, so it is dropped from the queue
with a warning naming the track.
Every other reason Last.fm declines to record one may not hold next time - a daily scrobble
limit resets, a wrong clock is corrected - so those stay queued and are warned about each
time.
Everything the queue could not submit is left in place, in order.

## EXAMPLES

### Example 1
```
PS C:\> Send-LFMScrobbleQueue
```

This will submit every pending scrobble the loaded configuration captured.

### Example 2
```
PS C:\> Send-LFMScrobbleQueue -WhatIf
```

This will report how many pending scrobbles would be submitted without submitting any.

### Example 3
```
PS C:\> Send-LFMScrobbleQueue -Verbose
```

This will submit every pending scrobble and report how many Last.fm recorded.

## PARAMETERS

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS

[Get-LFMScrobbleQueue](Get-LFMScrobbleQueue.md)

[Clear-LFMScrobbleQueue](Clear-LFMScrobbleQueue.md)

[Set-LFMTrackScrobble](Set-LFMTrackScrobble.md)
