function Get-LFMTrackInfo {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'track')]
    [OutputType('PowerLFM.Track.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'track')]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
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
            'UserName' {$apiParams.add('username', $UserName)}
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

        $tags = foreach ($tag in $irm.Track.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Tag'
                'Tag' = $tag.Name
                'Url' = $tag.Url
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
            'Id' = $irm.Track.Mbid
            'Listeners' = [int] $irm.Track.Listeners
            'PlayCount' = [int] $irm.Track.PlayCount
            'Url' = $irm.Track.Url
            'Tags' = $tags
        }

        $userPlayCount = $irm.Track.UserPlayCount
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $trackInfo.add('UserPlayCount', $userPlayCount)
            $trackInfo.add('Loved', $loved)
        }

        $trackInfo = [pscustomobject] $trackInfo
        Write-Output $trackInfo
    }
}
