function Get-LFMTrackSimilar {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'track')]
    [OutputType('PowerLFM.Track.Similar')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'track')]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'track')]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        [string] $Limit = '5',

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
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
        try {
            $irm = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
        }
        catch {
            $response = $_.errorDetails.message | ConvertFrom-Json

            [pscustomobject] @{
                'Error' = $response.error
                'Message' = $response.message
            }
            return
        }

        foreach ($similar in $irm.SimilarTracks.Track) {
            $similarInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Track.Similar'
                'Track' = $similar.Name
                'Artist' = $similar.Artist.Name
                'Id' = $similar.Mbid
                'PlayCount' = $similar.PlayCount
                'Url' = $similar.Url
                'Match' = $similar.Match
            }

            Write-Output $similarInfo
        }
    }
}
