function Get-LFMUserFriend {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Info')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1,50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getFriends'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
            'RecentTracks' {$apiParams.Add('recenttracks', 1)}
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
        try {
            $irm = Invoke-LFMApiUri -Uri $apiUrl
            if ($irm.Error) {Write-Output $irm; return}

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
