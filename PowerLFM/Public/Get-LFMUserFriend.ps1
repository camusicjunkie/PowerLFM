function Get-LFMUserFriend {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Info')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getFriends'
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

            foreach ($friend in $irm.Friends.User) {
                $userInfo = @{
                    'PSTypeName' = 'PowerLFM.User.Info'
                    'UserName' = $friend.Name
                    'RealName' = $friend.RealName
                    'Url' = [uri] $friend.Url
                    'Country' = $friend.Country
                    'Registered' = ConvertFrom-UnixTime -UnixTime $friend.Registered.UnixTime -Local
                    'PlayLists' = [int] $friend.PlayLists
                }

                $userInfo = [pscustomobject] $userInfo
                Write-Output $userInfo
            }
        }
        catch {
            throw $_
        }
    }
}
