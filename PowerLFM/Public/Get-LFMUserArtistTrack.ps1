function Get-LFMUserArtistTrack {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.ArtistTrack')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime] $StartDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime] $EndDate,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getArtistTracks'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        $apiParams.add('user', $UserName)
        $apiParams.add('artist', $Artist)

        if ($PSBoundParameters.Keys -clike '*Date') {
            $unixStartTime = ConvertTo-UnixTime -Date $StartDate
            $unixEndTime = ConvertTo-UnixTime -Date $EndDate

            $apiParams.add('startTimestamp', $unixStartTime)
            $apiParams.add('endTimestamp', $unixEndTime)
        }

        switch ($PSBoundParameters.Keys) {
            'Page' {$apiParams.add('page', $Page)}
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

        foreach ($track in $irm.ArtistTracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.Track'
                'Track' = $track.Name
                'Id' = $track.Mbid
                'Url' = $track.Url
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
                'Album' = $track.Album.'#text'
                'ScrobbleTime' = ConvertFrom-UnixTime -UnixTime ($track.Date.Uts) -Local
            }

            Write-Output $trackInfo
        }
    }
}
