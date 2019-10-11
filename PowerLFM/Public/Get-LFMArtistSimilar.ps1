function Get-LFMArtistSimilar {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Similar')]
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

        [int] $Limit,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'artist.getSimilar'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'AutoCorrect' {$apiParams.Add('autocorrect', 1)}
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'artist' {$apiParams.Add('artist', $Artist)}
            'id'     {$apiParams.Add('mbid', $Id)}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-LFMApiUri -Uri $apiUrl
        if ($irm.Error) {Write-Output $irm; return}

        foreach ($similar in $irm.SimilarArtists.Artist) {
            $similarInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Artist.Similar'
                'Artist' = $similar.Name
                'Id' = $similar.Mbid
                'Url' = [uri] $similar.Url
                'Match' = [math]::Round($similar.Match, 2)
            }

            Write-Output $similarInfo
        }
    }
}
