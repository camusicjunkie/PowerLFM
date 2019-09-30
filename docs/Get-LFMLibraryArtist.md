---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version:
schema: 2.0.0
---

# Get-LFMLibraryArtist

## SYNOPSIS
A paginated list of all the artists in a user's library, with play counts and tag counts.

## SYNTAX

```
Get-LFMLibraryArtist [[-UserName] <String>] [[-Limit] <String>] [[-Page] <String>] [<CommonParameters>]
```

## DESCRIPTION
A paginated list of all the artists in a user's library, with play counts and tag counts. This uses the library.getArtists method from the Last.fm API.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LFMLibraryArtist -UserName camusicjunkie
```

This will get a list of all the artists in camusicjunkie's library.

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

### -UserName
Username for the context of the request. The user whose library ou want to fetch are included in the response. Providing no user will use the currently authenticated user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

### PowerLFM.Library.Artist

## NOTES

## RELATED LINKS
