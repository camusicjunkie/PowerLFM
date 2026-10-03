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

    process {
        $irm = Invoke-LFMApiMethod -Method 'artist.getCorrection' -Parameter $PSBoundParameters

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
