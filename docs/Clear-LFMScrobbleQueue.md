---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Clear-LFMScrobbleQueue.md
schema: 2.0.0
---

# Clear-LFMScrobbleQueue

## SYNOPSIS
Discard every pending scrobble waiting in the scrobble queue.

## SYNTAX

```
Clear-LFMScrobbleQueue [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Discard every pending scrobble waiting in the scrobble queue.

Nothing is submitted to Last.fm.
A pending scrobble has no authoritative copy anywhere else, so discarding one destroys
listening history rather than a cached copy of it.
The command prompts for confirmation for that reason.

Run `Get-LFMScrobbleQueue` first to see what would be lost, or `Send-LFMScrobbleQueue` to
submit the queue instead of discarding it.

## EXAMPLES

### Example 1
```
PS C:\> Clear-LFMScrobbleQueue
```

This will prompt for confirmation and then discard every pending scrobble in the queue.

### Example 2
```
PS C:\> Clear-LFMScrobbleQueue -WhatIf
```

This will report how many pending scrobbles would be discarded without discarding any.

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

[Send-LFMScrobbleQueue](Send-LFMScrobbleQueue.md)
