function Get-LFMUserTopTag {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopTag')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [int] $Limit
    )

    begin {
        $apiParams = @{
            'method' = 'user.getTopTags'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.Add('limit', $Limit)}
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
        catch {
            throw $_
        }
    }
}
