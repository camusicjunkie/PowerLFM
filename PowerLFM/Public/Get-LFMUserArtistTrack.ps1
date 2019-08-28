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
        $apiParams.Add('user', $UserName)
        $apiParams.Add('artist', $Artist)

        if ($PSBoundParameters.Keys -clike '*Date') {
            $unixStartTime = ConvertTo-UnixTime -Date $StartDate
            $unixEndTime = ConvertTo-UnixTime -Date $EndDate

            $apiParams.Add('startTimestamp', $unixStartTime)
            $apiParams.Add('endTimestamp', $unixEndTime)
        }

        switch ($PSBoundParameters.Keys) {
            'Page' {$apiParams.Add('page', $Page)}
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

        foreach ($track in $irm.ArtistTracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.Track'
                'Track' = $track.Name
                'Id' = $track.Mbid
                'Url' = [uri] $track.Url
                'ImageUrl' = $track.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
                'Album' = $track.Album.'#text'
                'ScrobbleTime' = ConvertFrom-UnixTime -UnixTime ($track.Date.Uts) -Local
            }

            Write-Output $trackInfo
        }
    }
}
