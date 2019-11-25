function Get-LFMLibraryArtist {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Library.Artist')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'library.getArtists'
            'api_key' = $script:LFMConfig.APIKey
            'sk' = $script:LFMConfig.SessionKey
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

            foreach ($artist in $irm.Artists.Artist) {
                $artistInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Library.Artist'
                    'Artist' = $artist.Name
                    'PlayCount' = [int] $artist.PlayCount
                    'Url' = [uri] $artist.Url
                    'Id' = $artist.Mbid
                }

                Write-Output $artistInfo
            }
        }
        catch {
            throw $_
        }
    }
}
