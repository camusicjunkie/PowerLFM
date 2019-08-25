function Get-LFMArtistTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Tag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'artist')]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        [string] $UserName,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'artist.getTags'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'artist' {$apiParams.add('artist', $Artist)}
            'id'     {$apiParams.add('mbid', $Id)}
        }

        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.remove('sk')
            $apiParams.add('user', $UserName)
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

        foreach ($tag in $irm.Tags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Artist.Tag'
                'Tag' = $tag.Name
                'Url' = [uri] $tag.Url
            }

            Write-Output $tagInfo
        }
    }
}
