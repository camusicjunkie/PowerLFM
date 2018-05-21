function Get-LFMArtistTopTag {
    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.TopTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'artist')]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        [switch] $AutoCorrect
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'artist.getTopTags'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        #Adding key/value to hashtable based off ParameterSetName
        switch ($PSCmdlet.ParameterSetName) {
            'artist' {$apiParams.add('artist', $Artist)}
            'id' {$apiParams.add('mbid', $Id)}
        }

        #Adding key/value to hashtable based off optional parameters
        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
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
        
        $tags = foreach ($tag in $hash.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'Tag' = $tag.Name
                'Url' = $tag.Url
                'Match' = $tag.Count
            }
            $tagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Tag')
            Write-Output $tagInfo
        }

        $topTagInfo = [pscustomobject] @{
            'Artist' = $hash.TopTags.'@attr'.Artist
            'Tags' = $tags
        }

        $topTagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.TopTag')
        Write-Output $topTagInfo
    }
}