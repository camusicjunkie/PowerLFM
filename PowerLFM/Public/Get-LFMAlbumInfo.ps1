function Get-LFMAlbumInfo {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'album')]
    [OutputType('PowerLFM.Album.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 0,
                   ParameterSetName = 'album')]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 1,
                   ParameterSetName = 'album')]
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
            'method' = 'album.getInfo'
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
            'album' {$apiParams.add('artist', $Artist);
                     $apiParams.add('album', $Album)}
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

        $tracks = foreach ($track in $irm.Album.Tracks.Track) {
            $trackInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Track'
                'Track' = $track.Name
                'Duration' = $track.Duration
                'Url' = $track.Url
            }
            Write-Output $trackInfo
        }

        $tags = foreach ($tag in $irm.Album.Tags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Tag'
                'Tag' = $tag.Name
                'Url' = $tag.Url
            }
            Write-Output $tagInfo
        }

        $albumInfo = @{
            'PSTypeName' = 'PowerLFM.Album.Info'
            'Artist' = $irm.Album.Artist
            'Album' = $irm.Album.Name
            'Id' = $irm.Album.Mbid
            'Listeners' = [int] $irm.Album.Listeners
            'PlayCount' = [int] $irm.Album.PlayCount
            'Url' = $irm.Album.Url
            'Summary' = $irm.Album.Wiki.Summary
            'Tracks' = $tracks
            'Tags' = $tags
        }

        $userPlayCount = $irm.Album.UserPlayCount
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $albumInfo.add('UserPlayCount', $userPlayCount)
        }

        $albumInfo = [pscustomobject] $albumInfo
        Write-Output $albumInfo
    }
}
