function Get-LFMTrackSimilar {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'track')]
    [OutputType('PowerLFM.Track.Similar')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'track')]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'track')]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [string] $Limit = '5',
        [switch] $AutoCorrect
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'track.getSimilar'
            'api_key' = $LFMConfig.APIKey
            'limit' = $Limit
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'track' {$apiParams.add('track', $Track);
                     $apiParams.add('artist', $Artist)}
            'id'    {$apiParams.add('mbid', $Id)}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl
        $hash = $irm | ConvertTo-Hashtable

        foreach ($similar in $hash.SimilarTracks.Track) {
            $similarInfo = [pscustomobject] @{
                'Track' = $similar.Name
                'Artist' = $similar.Artist.Name
                'Id' = $similar.Mbid
                'PlayCount' = $similar.PlayCount
                'Url' = $similar.Url
                'Match' = $similar.Match
            }
            $similarInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Track.Similar')
            Write-Output $similarInfo
        }
    }
}
