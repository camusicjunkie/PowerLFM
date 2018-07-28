function Get-LFMAlbumTopTag {
    [CmdletBinding(DefaultParameterSetName = 'album')]
    [OutputType('PowerLFM.Album.TopTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'album')]
        [string] $Album,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'album')]
        [string] $Artist,

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [switch] $AutoCorrect
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'album.getTopTags'
            'api_key' = $LFMConfig.APIKey
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

        $tags = foreach ($tag in $hash.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'Tag' = $tag.Name
                'Url' = $tag.Url
                'Match' = $tag.Count
            }
            $tagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.Tag')
            Write-Output $tagInfo
        }

        $albumTagInfo = [pscustomobject] @{
            'Album' = $hash.TopTags.'@attr'.Album
            'Artist' = $hash.TopTags.'@attr'.Artist
            'Tags' = $tags
        }

        $albumTagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Album.TopTag')
        Write-Output $albumTagInfo
    }
}