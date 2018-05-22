function Get-LFMUserInfo {
    [CmdletBinding()]
    [OutputType('PowerLFM.User.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName
    )

    process {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'user.GetInfo'
            'api_key' = $LFMConfig.APIKey
            'user' = $UserName
            'format' = 'json'
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
        
        $registered = Convert-UnixTime($hash.User.Registered.UnixTime)
        $imageUrl = $hash.User.Image | Where-Object Size -eq ExtraLarge
        $userInfo = [pscustomobject] @{
            'UserName' = $hash.User.Name
            'RealName' = $hash.User.RealName
            'Url' = $hash.User.Url
            'Country' = $hash.User.Country
            'Registered' = $registered
            'PlayCount' = $hash.User.PlayCount
            'PlayLists' = $hash.User.PlayLists
            'ImageUrl' = $imageUrl.'#text'
            'Type' = $hash.User.Type
            'Age' = $hash.User.Age
            'Gender' = $hash.User.Gender
        }

        $userInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.Info')
        Write-Output $userInfo
    }
}