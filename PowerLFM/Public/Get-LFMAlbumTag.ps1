function Get-LFMAlbumTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'album')]
    [OutputType('PowerLFM.Album.UserTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'album')]
        [string] $Album,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'album')]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [string] $UserName,
        [switch] $AutoCorrect
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'album.getTags'
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
        }
    }
    process {
        #Adding key/value to hashtable based off ParameterSetName
        switch ($PSCmdlet.ParameterSetName) {
            'album' {$apiParams.add('album', $Album);
                     $apiParams.add('artist', $Artist)}
            'id'    {$apiParams.add('mbid', $Id)}
        }

        #Adding key/value to hashtable based off optional parameters
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.add('user', $UserName)
            $apiParams.add('api_key', $LFMConfig.APIKey)
        }
        else {
            $apiParams.add('api_key', $LFMConfig.APIKey)
            $apiParams.add('sk', $LFMConfig.SessionKey)
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

        $tags = foreach ($tag in $hash.Tags.Tag) {
            $tagInfo = [pscustomobject] @{
                'Tag' = $tag.Name
                'Url' = $tag.Url
            }
            $tagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.Tag')
            Write-Output $tagInfo
        }

        $artistTagInfo = [pscustomobject] @{
            'Artist' = $hash.Tags.'@attr'.Artist
            'Tags' = $tags
        }

        if ($PSBoundParameters.ContainsKey('UserName')) {
            $artistTagInfo | Add-Member -MemberType NoteProperty -Name 'UserName' -Value $UserName
        }

        $artistTagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.UserTag')
        Write-Output $artistTagInfo
    }
}
