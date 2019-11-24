---
external help file: PowerLFM-help.xml
Module Name: PowerLFM
online version: https://github.com/camusicjunkie/PowerLFM/blob/master/docs/Get-LFMArtistTopTrack.md
schema: 2.0.0
---

# Get-LFMArtistTopTrack

## SYNOPSIS
Get the top tracks for an artist.

## SYNTAX

### artist (Default)
```
Get-LFMArtistTopTrack [-Artist] <String> [-Limit <Int32>] [-Page <Int32>] [-AutoCorrect] [<CommonParameters>]
```

### id
```
Get-LFMArtistTopTrack -Id <Guid> [-Limit <Int32>] [-Page <Int32>] [-AutoCorrect] [<CommonParameters>]
```

## DESCRIPTION
Get the top tracks for an artist, ordered by popularity.
This uses the artist.getTopTracks method from the Last.fm API.

## EXAMPLES

### Example 1
```
PS C:\> Get-LFMArtistTopTrack -Artist Deftones
```

This will get the top Deftones tracks, ordered by popularity.

## PARAMETERS

### -Artist
Name of the artist.

```yaml
Type: String
Parameter Sets: artist
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AutoCorrect
Transform misspelled artist names into correct artist names.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Musicbrainz id for the artist.

```yaml
Type: Guid
Parameter Sets: id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Limit
Limit the number of results per page.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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

### PowerLFM.Artist.Track
## NOTES

## RELATED LINKS
