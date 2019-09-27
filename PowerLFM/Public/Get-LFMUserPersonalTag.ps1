function Get-LFMUserPersonalTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.PersonalTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Tag,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Artist', 'Album', 'Track')]
        [string] $TagType,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getPersonalTags'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
            'Page' {$apiParams.Add('page', $Page)}
        }
    }
    process {
        $apiParams.Add('user', $UserName)
        $apiParams.Add('tag', $Tag)
        $apiParams.Add('taggingtype', $TagType.ToLower())

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
