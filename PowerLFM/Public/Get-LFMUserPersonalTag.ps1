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
        try {
            $irm = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
        }
        catch {
            $response = $_.errorDetails.message | ConvertFrom-Json

            [pscustomobject] @{
                'Error' = $response.error
                'Message' = $response.message
            }
            return
        }

        foreach ($userTag in $irm.Taggings.Artists.Artist) {
            $userTagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.PersonalTag'
                'Artist' = $userTag.name
                'Id' = $userTag.mbid
                'Url' = $userTag.url
            }

            Write-Output $userTagInfo
        }
    }
}
