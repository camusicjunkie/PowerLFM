function Get-LFMTagTopTrack {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Tag.TopTracks')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'tag.getTopTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
        }
    }
    process {
        $apiParams.add('tag', $Tag)

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
            if ($irm.error) {
                [pscustomobject] @{
                    'Error' = $irm.error
                    'Message' = $irm.message
                }
                return
            }
        }
        catch {
            $response = $_.errorDetails.message | ConvertFrom-Json

            [pscustomobject] @{
                'Error' = $response.error
                'Message' = $response.message
            }
            return
        }

        foreach ($track in $irm.Tracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Tag.TopTracks'
                'Track' = $track.Name
                'TrackId' = [guid] $track.Mbid
                'TrackUrl' = [uri] $track.Url
                'Artist' = $track.Artist.Name
                'ArtistId' = [guid] $track.Artist.Mbid
                'ArtistUrl' = [uri] $track.Artist.Url
                'Rank' = [int] $track.'@attr'.Rank
                'Duration' = [int] $track.Duration
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            Write-Output $trackInfo
        }
    }
}
