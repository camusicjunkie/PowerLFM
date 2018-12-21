function Get-LFMUserPersonalTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.PersonalTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Tag,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateSet('Artist', 'Album', 'Track')]
        [string] $TagType,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'user.getPersonalTags'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
        }
    }
    process {
        $apiParams.add('user', $UserName)
        $apiParams.add('tag', $Tag)
        $apiParams.add('taggingtype', $TagType.ToLower())

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl

        foreach ($userTag in $irm.Taggings.Artists.Artist) {
            $userTagInfo = [pscustomobject] @{
                'Artist' = $userTag.name
                'Id' = $userTag.mbid
                'Url' = $userTag.url
            }

            $userTagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.PersonalTag')
            Write-Output $userTagInfo
        }
    }
}
