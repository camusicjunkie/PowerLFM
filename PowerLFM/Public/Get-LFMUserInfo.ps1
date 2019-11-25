function Get-LFMUserInfo {
    # .ExternalHelp PowerLFM-help.xml

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
            'api_key' = $script:LFMConfig.APIKey
            'sk' = $script:LFMConfig.SessionKey
            'format' = 'json'
        }
    }
    process {
        $noCommonParams = Remove-CommonParameter $PSBoundParameters
        $convertedParams = ConvertTo-LFMParameter $noCommonParams

        $query = New-LFMApiQuery ($convertedParams + $apiParams)
        $apiUrl = "$baseUrl/?$query"
    }
    end {
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl

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
        catch {
            throw $_
        }
    }
}
