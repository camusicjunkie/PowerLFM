---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
schema: 2.0.0
---

# Remove-LFMArtistTag

## SYNOPSIS
Untag an artist using a user supplied tag.

## SYNTAX

```
Remove-LFMArtistTag [-Artist] <String> [-Tag] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Untag an artist using a user supplied tag. This uses the artist.removeTag method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-LFMArtistTag -Artist Deftones -Tag Rock
```

This will remove the rock tag from the artist Deftones

## PARAMETERS

### -Artist
Name of the artist.

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

### -Tag
Name of the tag.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

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

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/artist.removeTag](https://www.last.fm/api/show/artist.removeTag)
