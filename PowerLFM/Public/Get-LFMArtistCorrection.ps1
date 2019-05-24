function Get-LFMArtistCorrection {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Artist.Correction')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist
    )

    begin {
        $apiParams = @{
            'method' = 'artist.getCorrection'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        $apiParams.add('artist', $Artist)

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

        $correction = $irm.Corrections.Correction.Artist
        $correctedArtistInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Artist.Correction'
            'Artist' = $correction.Name
            'Id' = $correction.Mbid
            'Url' = $correction.Url
        }

        Write-Output $correctedArtistInfo
    }
}
