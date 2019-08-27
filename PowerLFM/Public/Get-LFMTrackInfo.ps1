function Get-LFMTrackInfo {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'track')]
    [OutputType('PowerLFM.Track.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 0,
                   ParameterSetName = 'track')]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 1,
                   ParameterSetName = 'track')]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        [string] $UserName,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'track.getInfo'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.Add('username', $UserName)}
            'AutoCorrect' {$apiParams.Add('autocorrect', 1)}
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'track' {$apiParams.Add('track', $Track);
                     $apiParams.Add('artist', $Artist)}
            'id'    {$apiParams.Add('mbid', $Id)}
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

        $tags = foreach ($tag in $irm.Track.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Tag'
                'Tag' = $tag.Name
                'Url' = [uri] $tag.Url
            }
            Write-Output $tagInfo
        }

        switch ($irm.Track.UserLoved) {
            '0' {$loved = 'No'}
            '1' {$loved = 'Yes'}
        }

        $trackInfo = @{
            'PSTypeName' = 'PowerLFM.Album.Info'
            'Track' = $irm.Track.Name
            'Artist' = $irm.Track.Artist.Name
            'Album' = $irm.Track.Album.Title
            'Id' = [guid] $irm.Track.Mbid
            'Listeners' = [int] $irm.Track.Listeners
            'PlayCount' = [int] $irm.Track.PlayCount
            'Url' = [uri] $irm.Track.Url
            'Tags' = $tags
        }

        $userPlayCount = [int] $irm.Track.UserPlayCount
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $trackInfo.Add('UserPlayCount', $userPlayCount)
            $trackInfo.Add('Loved', $loved)
        }

        $trackInfo = [pscustomobject] $trackInfo
        Write-Output $trackInfo
    }
}
