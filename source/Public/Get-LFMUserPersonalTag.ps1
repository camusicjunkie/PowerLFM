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

    process {
        $irm = Invoke-LFMApiMethod -Method 'user.getPersonalTags' -Parameter $PSBoundParameters

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
}
