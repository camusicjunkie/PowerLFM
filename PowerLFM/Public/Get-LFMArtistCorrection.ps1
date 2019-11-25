function Get-LFMArtistCorrection {
    # .ExternalHelp PowerLFM-help.xml

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
            'api_key' = $script:LFMConfig.APIKey
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

            $correction = $irm.Corrections.Correction.Artist
            $correctedArtistInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Artist.Correction'
                'Artist' = $correction.Name
                'Id' = $correction.Mbid
                'Url' = [uri] $correction.Url
            }

            Write-Output $correctedArtistInfo
        }
        catch {
            throw $_
        }
    }
}
