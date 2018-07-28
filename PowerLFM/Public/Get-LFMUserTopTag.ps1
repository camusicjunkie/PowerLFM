function Get-LFMUserTopTag {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [string] $Limit
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'user.getTopTags'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        #Adding key/value to hashtable based off optional parameters
        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.add('user', $UserName)}
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
         
        foreach ($tag in $hash.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'Tag' = $tag.Name
                'TagUrl' = $tag.url
                'Count' = $tag.Count
            }

            $tagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.TopTag')
            Write-Output $tagInfo
        }
    }
}