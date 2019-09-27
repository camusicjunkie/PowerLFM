function Get-LFMUserTopTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [string] $Limit
    )

    begin {
        $apiParams = @{
            'method' = 'user.getTopTags'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
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
        $irm = Invoke-LFMApiUri -Uri $apiUrl
        if ($irm.Error) {Write-Output $irm; return}

        foreach ($tag in $irm.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.TopTag'
                'Tag' = $tag.Name
                'TagUrl' = [uri] $tag.Url
                'Count' = [int] $tag.Count
            }

            Write-Output $tagInfo
        }
    }
}
