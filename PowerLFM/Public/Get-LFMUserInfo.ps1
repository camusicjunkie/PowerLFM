function Get-LFMUserInfo {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Info')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $UserName
    )

    begin {
        $apiParams = @{
            'method' = 'user.GetInfo'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }
    }
    process {
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.Remove('sk')
            $apiParams.Add('user', $UserName)
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

        $userInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.User.Info'
            'UserName' = $irm.User.Name
            'RealName' = $irm.User.RealName
            'Url' = $irm.User.Url
            'Country' = $irm.User.Country
            'Registered' = ConvertFrom-UnixTime -UnixTime $irm.User.Registered.UnixTime -Local
            'PlayCount' = [int] $irm.User.PlayCount
            'PlayLists' = $irm.User.PlayLists
            'ImageUrl' = $irm.User.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
        }

        Write-Output $userInfo
    }
}
