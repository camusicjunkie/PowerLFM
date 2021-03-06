function Get-LFMArtistInfo {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Info')]
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

        [string] $UserName,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'artist.getInfo'
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

            $similarArtists = foreach ($similar in $irm.Artist.Similar.Artist) {
                $similarInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Artist.Similar'
                    'Artist' = $similar.Name
                    'Url' = [uri] $similar.Url
                }

                Write-Output $similarInfo
            }

            $tags = foreach ($tag in $irm.Artist.Tags.Tag) {
                $tagInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Artist.Tag'
                    'Tag' = $tag.Name
                    'Url' = [uri] $tag.Url
                }

                Write-Output $tagInfo
            }

            switch ($irm.Artist.OnTour) {
                '0' {$tour = 'No'}
                '1' {$tour = 'Yes'}
            }

            $artistInfo = @{
                'PSTypeName' = 'PowerLFM.Artist.Info'
                'Artist' = $irm.Artist.Name
                'Id' = $irm.Artist.Mbid
                'Listeners' = [int] $irm.Artist.Stats.Listeners
                'PlayCount' = [int] $irm.Artist.Stats.PlayCount
                'OnTour' = $tour
                'Url' = [uri] $irm.Artist.Url
                'Summary' = $irm.Artist.Bio.Summary
                'SimilarArtists' = $similarArtists
                'Tags' = $tags
            }

            $userPlayCount = [int] $irm.Artist.Stats.UserPlayCount
            if ($PSBoundParameters.ContainsKey('UserName')) {
                $artistInfo.Add('UserPlayCount', $userPlayCount)
            }

            $artistInfo = [pscustomobject] $artistInfo
            Write-Output $artistInfo
        }
        catch {
            throw $_
        }
    }
}
