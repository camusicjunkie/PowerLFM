---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: null
schema: 2.0.0
---

# Get-LFMTagTopTag

## SYNOPSIS

Get the top tags, ordered by popularity.

## SYNTAX

```text
Get-LFMTagTopTag [<CommonParameters>]
```

## DESCRIPTION

Get the top tags, ordered by popularity. This uses the tag.getTopTags method from the Last.fm API.

## EXAMPLES

### Example 1

```text
PS C:\> Get-LFMTagTopTag
```

Gets the top tags.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### PowerLFM.Tag.TopTags

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/tag.getTopTags](https://www.last.fm/api/show/tag.getTopTags)

