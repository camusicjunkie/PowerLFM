# Get-LFMArtistCorrection

## SYNOPSIS
Check to see if there is a correction.

## SYNTAX

```
Get-LFMArtistCorrection [-Artist] <String> [<CommonParameters>]
```

## DESCRIPTION
Checks the Last.fm database to see if a correction can be made. This uses the artist.getCorrection method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMArtistCorrection -Artist Deftone
```

Transforms Deftone in to the correct artist name Deftones.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### PowerLFM.Artist.Correction

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/artist.getCorrection](https://www.last.fm/api/show/artist.getCorrection)
