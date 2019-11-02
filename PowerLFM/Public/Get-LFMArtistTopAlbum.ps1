function Get-LFMArtistTopAlbum {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Album')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 0,
                   ParameterSetName = 'artist')]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [ValidateNotNullOrEmpty()]
        [guid] $Id,

        [Parameter()]
        [ValidateRange(1,50)]
        [int] $Limit,

        [int] $Page,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'artist.getTopAlbums'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.Add('autocorrect', 1)}
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'artist' {$apiParams.Add('artist', $Artist)}
            'id' {$apiParams.Add('mbid', $Id)}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl

            foreach ($album in $irm.TopAlbums.Album) {
                $albumInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Artist.Album'
                    'Album' = $album.Name
                    'Id' = $album.Mbid
                    'Url' = [uri]$album.Url
                    'PlayCount' = [int] $album.PlayCount
                }

                Write-Output $albumInfo
            }
        }
        catch {
            throw $_
        }
    }
}
