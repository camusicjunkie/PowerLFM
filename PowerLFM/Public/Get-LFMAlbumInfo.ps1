function Get-LFMAlbumInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'album')]
        [string] $Artist,

        [Parameter(Mandatory,
                   ParameterSetName = 'album')]
        [string] $Album,

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [string] $UserName,
        [string] $Language,

        [Parameter()]
        [ValidateSet('0', '1')]
        [string] $AutoCorrect
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'album.getInfo'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
        #Adding key/value to hashtable based off ParameterSetName
        if ($PSCmdlet.ParameterSetName -eq 'album') {
            $apiParams.add('artist', $Artist)
            $apiParams.add('album', $Album)
        }
        if ($PSCmdlet.ParameterSetName -eq 'id') {
            $apiParams.add('mbid', $Id)
        }
        #Adding key/value to hashtable based off optional parameters
        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.add('username', $UserName)}
            'Language' {$apiParams.add('lang', $Language)}
            'AutoCorrect' {$apiParams.add('autocorrect', $AutoCorrect)}
        }
        
        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    process {
        $iwr = Invoke-WebRequest -Uri $apiUrl
        $jsonString = $iwr.AllElements[3].innerHTML
        $hash = $jsonString | ConvertFrom-Json | ConvertTo-HashTable

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
                'Tag' = $tag.Name
                'Url' = $tag.Url
            }
            $tagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.Tag')
            Write-Output $tagInfo
        }

        $albumInfo = [pscustomobject] @{
            'Artist' = $hash.Album.Artist
            'Album' = $hash.Album.Name
            'Id' = $hash.Album.Mbid
            'Listeners' = $hash.Album.Listeners
            'PlayCount' = $hash.Album.PlayCount
            'UserName' = $UserName
            'UserPlayCount' = $hash.Album.UserPlayCount
            'Summary' = $hash.Album.Wiki.Summary
            'Tracks' = $tracks
            'Tags' = $tags
        }
        #if ($PSCmdlet.ParameterSetName('Album')) {
        #    $albumInfo | Add-Member -MemberType NoteProperty -Name Artist -Value $hash.Album.Artist
        #    $albumInfo | Add-Member -MemberType NoteProperty -Name Album -Value $hash.Album.Name
        #}
        #if ($PSCmdlet.ParameterSetName('Id')) {
        #    $albumInfo | Add-Member -MemberType NoteProperty -Name Id -Value $hash.Album.Mbid
        #}
        #if ($PSBoundParameters.ContainsKey('UserName')) {
        #    $albumInfo.add('UserName', $UserName)
        #    $albumInfo.add('UserPlayCount', $hash.Album.UserPlayCount)
        #}

        $albumInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.Info')
        Write-Output $albumInfo
    }
}