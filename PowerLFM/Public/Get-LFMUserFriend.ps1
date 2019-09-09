function Get-LFMUserFriend {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getFriends'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
            'RecentTracks' {$apiParams.Add('recenttracks', 1)}
        }
    }
    process {
        $apiParams.Add('user', $UserName)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        try {
            $irm = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
            if ($irm.error) {
                [pscustomobject] @{
                    'Error' = $irm.error
                    'Message' = $irm.message
                }
                return
            }
        }
        catch {
            $response = $_.errorDetails.message | ConvertFrom-Json

            [pscustomobject] @{
                'Error' = $response.error
                'Message' = $response.message
            }
            return
        }

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
}
