function Get-LFMUserTopAlbum {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopAlbum')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter()]
        [ValidateSet('Overall', '7 Days', '1 Month',
                     '3 Months', '6 Months', '1 Year')]
        [string] $TimePeriod,

        [Parameter()]
        [ValidateRange(1, 50)]
        [int] $Limit,

        [int] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'user.getTopAlbums'
            'api_key' = $script:LFMConfig.ApiKey
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

            foreach ($album in $irm.TopAlbums.Album) {
                $albumInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.User.Album'
                    'Album' = $album.Name
                    'PlayCount' = [int] $album.PlayCount
                    'AlbumUrl' = [uri] $album.Url
                    'AlbumId' = $album.Mbid
                    'Artist' = $album.Artist.Name
                    'ArtistUrl' = [uri] $album.Artist.Url
                    'ArtistId' = $album.Artist.Mbid
                }

                Write-Output $albumInfo
            }
        }
        catch {
            throw $_
        }
    }
}
