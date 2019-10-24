---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMTagInfo

## SYNOPSIS
Get the metadata for a tag.

## SYNTAX

```
Get-LFMTagInfo [-Tag] <String> [[-Language] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the metadata for a tag. This uses the tag.getInfo method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMTagInfo -Tag rock -Language en
```

Get info for the tag rock. The summary will be returned in the language specified.

## PARAMETERS

### -Language
Language to return the wiki in, expressed as an ISO 639 alpha-2 code. Ex. 'en' for spanish.

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

### PowerLFM.Tag.Info

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/tag.getInfo](https://www.last.fm/api/show/tag.getInfo)