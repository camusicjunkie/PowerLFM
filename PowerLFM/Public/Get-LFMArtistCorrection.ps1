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
        $apiParams.Add('artist', $Artist)

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

        $correction = $irm.Corrections.Correction.Artist
        $correctedArtistInfo = [pscustomobject] @{
            'PSTypeName' = 'PowerLFM.Artist.Correction'
            'Artist' = $correction.Name
            'Id' = $correction.Mbid
            'Url' = [uri] $correction.Url
        }

        Write-Output $correctedArtistInfo
    }
}
