---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMTagTopTrack.md
schema: 2.0.0
---

# Get-LFMTagTopTrack

## SYNOPSIS
Get the top tracks tagged by this tag, ordered by tag count.

## SYNTAX

```
Get-LFMTagTopTrack [-Tag] <String> [[-Limit] <Int32>] [[-Page] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Get the top artists tagged by this tag, ordered by tag count.
This uses the tag.getTopTracks method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMTagTopTrack -Tag rock
```

This will get the top tracks with the tag rock, ordered by tag count.

## PARAMETERS

### -Limit
Limit the number of results per page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Name of the tag.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### PowerLFM.Tag.TopTracks
## NOTES

## RELATED LINKS
