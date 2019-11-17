function Get-LFMTrackInfo {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding(DefaultParameterSetName = 'track')]
    [OutputType('PowerLFM.Track.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 0,
                   ParameterSetName = 'track')]
        [ValidateNotNullOrEmpty()]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position = 1,
                   ParameterSetName = 'track')]
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
            'method' = 'track.getInfo'
            'api_key' = $LFMConfig.APIKey
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

            $tags = foreach ($tag in $irm.Track.TopTags.Tag) {
                $tagInfo = [pscustomobject] @{
                    'PSTypeName' = 'PowerLFM.Album.Tag'
                    'Tag' = $tag.Name
                    'Url' = [uri] $tag.Url
                }
                Write-Output $tagInfo
            }

            switch ($irm.Track.UserLoved) {
                '0' {$loved = 'No'}
                '1' {$loved = 'Yes'}
            }

            $trackInfo = @{
                'PSTypeName' = 'PowerLFM.Album.Info'
                'Track' = $irm.Track.Name
                'Artist' = $irm.Track.Artist.Name
                'Album' = $irm.Track.Album.Title
                'Id' = $irm.Track.Mbid
                'Listeners' = [int] $irm.Track.Listeners
                'PlayCount' = [int] $irm.Track.PlayCount
                'Url' = [uri] $irm.Track.Url
                'Tags' = $tags
            }

            $userPlayCount = [int] $irm.Track.UserPlayCount
            if ($PSBoundParameters.ContainsKey('UserName')) {
                $trackInfo.Add('UserPlayCount', $userPlayCount)
                $trackInfo.Add('Loved', $loved)
            }

            $trackInfo = [pscustomobject] $trackInfo
            Write-Output $trackInfo
        }
        catch {
            throw $_
        }
    }
}
