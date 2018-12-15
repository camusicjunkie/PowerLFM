function Get-LFMAlbumInfo {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'album')]
    [OutputType('PowerLFM.Album.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'album')]
        [string] $Artist,

        [Parameter(Mandatory,
                   ParameterSetName = 'album')]
        [string] $Album,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [string] $UserName,
        [switch] $AutoCorrect
    )

    begin {
        $apiParams = [ordered] @{
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
        $hash = $irm | ConvertTo-Hashtable

        $i = 1
        $tracks = foreach ($track in $hash.Album.Tracks.Track) {
            $trackInfo = [pscustomobject] @{
                'Track' = $i
                'Title' = $track.Name
                'Duration' = $track.Duration
                'Url' = $track.Url
            }
            $i++
            $trackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.Track')
            Write-Output $trackInfo
        }

        $tags = foreach ($tag in $hash.Album.Tags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Tag'
                'Tag' = $tag.Name
                'Url' = $tag.Url
            }
            Write-Output $tagInfo
        }

        $albumInfo = [pscustomobject] @{
            'Artist' = $hash.Album.Artist
            'Album' = $hash.Album.Name
            'Id' = $hash.Album.Mbid
            'Listeners' = [int] $hash.Album.Listeners
            'PlayCount' = [int] $hash.Album.PlayCount
            'Url' = $hash.Album.Url
            'Summary' = $hash.Album.Wiki.Summary
            'Tracks' = $tracks
            'Tags' = $tags
        }

        $userPlayCount = $hash.Album.UserPlayCount
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $albumInfo | Add-Member -MemberType NoteProperty -Name 'UserName' -Value $UserName
            $albumInfo | Add-Member -MemberType NoteProperty -Name 'UserPlayCount' -Value $userPlayCount
        }

        $albumInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.Info')
        Write-Output $albumInfo
    }
}
