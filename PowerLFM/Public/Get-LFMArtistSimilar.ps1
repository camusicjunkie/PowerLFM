function Get-LFMArtistSimilar {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Similar')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 0,
                   ParameterSetName = 'artist')]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        [string] $Limit = '5',

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'artist.getSimilar'
            'api_key' = $LFMConfig.APIKey
            'limit' = $Limit
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.Add('autocorrect', 1)}
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'artist' {$apiParams.Add('artist', $Artist)}
            'id'     {$apiParams.Add('mbid', $Id)}
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

        foreach ($similar in $irm.SimilarArtists.Artist) {
            $similarInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Artist.Similar'
                'Artist' = $similar.Name
                'Id' = $similar.Mbid
                'Url' = [uri] $similar.Url
                'Match' = [math]::Round($similar.Match, 2)
            }

            Write-Output $similarInfo
        }
    }
}
