function Get-LFMArtistInfo {
    # .ExternalHelp PowerLFM.psm1-help.xml

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
        [string] $Id,

        [string] $UserName,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'artist.getInfo'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.add('username', $UserName)}
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'artist' {$apiParams.add('artist', $Artist)}
            'id'     {$apiParams.add('mbid', $Id)}
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

        $similarArtists = foreach ($similar in $irm.Artist.Similar.Artist) {
            $similarInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Artist.Similar'
                'Artist' = $similar.Name
                'Url' = $similar.Url
            }

            Write-Output $similarInfo
        }

        $tags = foreach ($tag in $irm.Artist.Tags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Artist.Tag'
                'Tag' = $tag.Name
                'Url' = $tag.Url
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
            'Url' = $irm.Artist.Url
            'Summary' = $irm.Artist.Bio.Summary
            'SimilarArtists' = $similarArtists
            'Tags' = $tags
        }

        $userPlayCount = $irm.Artist.Stats.UserPlayCount
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $artistInfo.add('UserPlayCount', $userPlayCount)
        }

        $artistInfo = [pscustomobject] $artistInfo
        Write-Output $artistInfo
    }
}
