function Get-LFMUserInfo {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.Info')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'user.getInfo' -Parameter $PSBoundParameters

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
