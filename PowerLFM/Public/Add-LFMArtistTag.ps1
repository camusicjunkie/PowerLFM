function Add-LFMArtistTag {
    [CmdletBinding(DefaultParameterSetName = 'tag')]
    [OutputType('PowerLFM.Artist.Tag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateCount(1,10)]
        [string[]] $Tag
    )

    begin {
        $apiSig = New-LFMArtistSignature -Method artist.addTags -Artist $Artist -Tag $Tag
        
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'artist.addTags'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'api_sig' = $apiSig
            'format' = 'json'
        }
    }
    process {
        #Adding key/value to hashtable. Added in the process block
        #to allow for pipeline input
        $apiParams.add('artist', $Artist)
        $apiParams.add('tags', $Tag)
        
        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $iwr = Invoke-WebRequest -Uri $apiUrl -Method Post -Body "$string$($LFMConfig.SharedSecret)"
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