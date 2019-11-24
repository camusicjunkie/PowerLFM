---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMTagSimilar.md
schema: 2.0.0
---

# Get-LFMTagSimilar

## SYNOPSIS
Get tags similar to the one specified.

## SYNTAX

```
Get-LFMTagSimilar [-Tag] <String> [<CommonParameters>]
```

## DESCRIPTION
Get tags similar to the one specified.
Returns tags ranked by similarity, based on listening data.
This uses the tag.getSimilar method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMTagSimilar -Tag rock
```

Get similar tags to the rock tag.

## PARAMETERS

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

### PowerLFM.Tag.Similar
## NOTES

## RELATED LINKS
