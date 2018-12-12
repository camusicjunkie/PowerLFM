function Get-LFMArtistCorrection {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Artist.Correction')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'artist.getCorrection'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'Artist' {$apiParams.add('artist', $Artist)}
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-RestMethod -Uri $apiUrl
        $hash = $irm | ConvertTo-Hashtable

        $correctedArtistInfo = [pscustomobject] @{
            'Artist' = $hash.Corrections.Correction.Artist.Name
            'Id' = $hash.Corrections.Correction.Artist.Mbid
            'Url' = $hash.Corrections.Correction.Artist.Url
        }

        $correctedArtistInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Correction')
        Write-Output $correctedArtistInfo
    }
}
