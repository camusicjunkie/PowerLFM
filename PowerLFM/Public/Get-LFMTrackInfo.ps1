function Get-LFMTrackInfo {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'track')]
    [OutputType('PowerLFM.Track.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'track')]
        [string] $Track,

        [Parameter(Mandatory,
                   ParameterSetName = 'track')]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [string] $UserName,
        [switch] $AutoCorrect
    )

    begin {
        $apiParams = [ordered] @{
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
        $hash = $irm | ConvertTo-Hashtable

        $tags = foreach ($tag in $hash.Track.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Tag'
                'Tag' = $tag.Name
                'Url' = $tag.Url
            }
            Write-Output $tagInfo
        }

        switch ($hash.Track.UserLoved) {
            '0' {$loved = 'No'}
            '1' {$loved = 'Yes'}
        }

        $trackInfo = [pscustomobject] @{
            'Track' = $hash.Track.Name
            'Artist' = $hash.Track.Artist.Name
            'Album' = $hash.Track.Album.Title
            'Id' = $hash.Track.Mbid
            'Listeners' = [int] $hash.Track.Listeners
            'PlayCount' = [int] $hash.Track.PlayCount
            'Url' = $hash.Track.Url
            'Tags' = $tags
        }

        $userPlayCount = $hash.Track.UserPlayCount
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $trackInfo | Add-Member -MemberType NoteProperty -Name 'UserName' -Value $UserName
            $trackInfo | Add-Member -MemberType NoteProperty -Name 'UserPlayCount' -Value $userPlayCount
            $trackInfo | Add-Member -MemberType NoteProperty -Name 'Loved' -Value $loved
        }

        $trackInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.Info')
        Write-Output $trackInfo
    }
}
