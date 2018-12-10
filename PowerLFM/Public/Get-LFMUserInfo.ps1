function Get-LFMUserInfo {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Info')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $UserName
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'user.GetInfo'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }
    }
    process {
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.remove('sk')
            $apiParams.add('user', $UserName)
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

        $registered = ConvertFrom-UnixTime -UnixTime $hash.User.Registered.UnixTime -Local
        $imageUrl = $hash.User.Image | Where-Object Size -eq ExtraLarge
        $userInfo = [pscustomobject] @{
            'UserName' = $hash.User.Name
            'RealName' = $hash.User.RealName
            'Url' = $hash.User.Url
            'Country' = $hash.User.Country
            'Registered' = $registered
            'PlayCount' = [int] $hash.User.PlayCount
            'PlayLists' = $hash.User.PlayLists
            'ImageUrl' = $imageUrl.'#text'
        }

        $userInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.Info')
        Write-Output $userInfo
    }
}
