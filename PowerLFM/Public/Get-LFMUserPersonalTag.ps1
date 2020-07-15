function Get-LFMUserPersonalTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.PersonalTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Artist', 'Album', 'Track')]
        [string] $TagType,

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
            'method' = 'user.getPersonalTags'
            'api_key' = $script:LFMConfig.ApiKey
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

            foreach ($userTag in $irm.Taggings.Artists.Artist) {
                $userTagInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.User.PersonalTag'
                    'Artist' = $userTag.Name
                    'Id' = $userTag.Mbid
                    'Url' = [uri] $userTag.Url
                }

                Write-Output $userTagInfo
            }
        }
        catch {
            throw $_
        }
    }
}
