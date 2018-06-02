function Get-LFMArtistTag {
    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.UserTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'artist')]
        [string] $Artist,

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [string] $UserName,
        [switch] $AutoCorrect
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'artist.getTags'
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
        }
    }
    process {
        #Adding key/value to hashtable based off ParameterSetName
        switch ($PSCmdlet.ParameterSetName) {
            'artist' {$apiParams.add('artist', $Artist)}
            'id' {$apiParams.add('mbid', $Id)}
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
        $iwr = Invoke-WebRequest -Uri $apiUrl
        $jsonString = $iwr.AllElements[3].innerHTML
        $hash = $jsonString | ConvertFrom-Json | ConvertTo-HashTable

        $tags = foreach ($tag in $hash.Tags.Tag) {
            $tagInfo = [pscustomobject] @{
                'Tag' = $tag.Name
                'Url' = $tag.Url
            }
            $tagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Tag')
            Write-Output $tagInfo
        }

        $artistTagInfo = [pscustomobject] @{
            'Artist' = $hash.Tags.'@attr'.Artist
            'Tags' = $tags
        }

        if ($PSBoundParameters.ContainsKey('UserName')) {
            $artistTagInfo | Add-Member -MemberType NoteProperty -Name 'UserName' -Value $UserName
        }

        $artistTagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.UserTag')
        Write-Output $artistTagInfo
    }
}