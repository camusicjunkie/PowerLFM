function Get-LFMAlbumInfo {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'album')]
    [OutputType('PowerLFM.Album.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 0,
                   ParameterSetName = 'album')]
        [ValidateNotNullOrEmpty()]
        [string] $Album,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 1,
                   ParameterSetName = 'album')]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [ValidateNotNullOrEmpty()]
        [guid] $Id,

        [string] $UserName,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'album.getInfo'
            'api_key' = $script:LFMConfig.ApiKey
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

            $tracks = foreach ($track in $irm.Album.Tracks.Track) {
                $trackInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Album.Track'
                    'Track' = $track.Name
                    'Duration' = [int] $track.Duration
                    'Url' = [uri] $track.Url
                }
                Write-Output $trackInfo
            }

            $tags = foreach ($tag in $irm.Album.Tags.Tag) {
                $tagInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Album.Tag'
                    'Tag' = $tag.Name
                    'Url' = [uri] $tag.Url
                }
                Write-Output $tagInfo
            }

            $albumInfo = @{
                'PSTypeName' = 'PowerLFM.Album.Info'
                'Artist' = $irm.Album.Artist
                'Album' = $irm.Album.Name
                'Id' = $irm.Album.Mbid
                'Listeners' = [int] $irm.Album.Listeners
                'PlayCount' = [int] $irm.Album.PlayCount
                'Url' = [uri] $irm.Album.Url
                'Summary' = $irm.Album.Wiki.Summary
                'Tracks' = $tracks
                'Tags' = $tags
            }

            $userPlayCount = [int] $irm.Album.UserPlayCount
            if ($PSBoundParameters.ContainsKey('UserName')) {
                $albumInfo.Add('UserPlayCount', $userPlayCount)
            }

            $albumInfo = [pscustomobject] $albumInfo
            Write-Output $albumInfo
        }
        catch {
            throw $_
        }
    }
}
