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

        $correction = $hash.Corrections.Correction.Artist
        $correctedArtistInfo = [pscustomobject] @{
            'Artist' = $correction.Name
            'Id' = $correction.Mbid
            'Url' = $correction.Url
        }

        $correctedArtistInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Correction')
        Write-Output $correctedArtistInfo
    }
}
