function Get-LFMUserInfo {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Info')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
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
        $irm = Invoke-LFMApiUri -Uri $apiUrl
        if ($irm.Error) {Write-Output $irm; return}

        $userInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.User.Info'
            'UserName' = $irm.User.Name
            'RealName' = $irm.User.RealName
            'Url' = [uri] $irm.User.Url
            'Country' = $irm.User.Country
            'Registered' = ConvertFrom-UnixTime -UnixTime $irm.User.Registered.UnixTime -Local
            'PlayCount' = [int] $irm.User.PlayCount
            'PlayLists' = [int] $irm.User.PlayLists
        }

        Write-Output $userInfo
    }
}
