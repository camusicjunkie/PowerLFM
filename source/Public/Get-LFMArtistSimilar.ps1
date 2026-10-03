function Get-LFMArtistSimilar {
    # .ExternalHelp PowerLFM-help.xml

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
        [guid] $Id,

        [int] $Limit,

        [switch] $AutoCorrect
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'artist.getSimilar' -Parameter $PSBoundParameters

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
