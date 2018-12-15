function Get-LFMArtistInfo {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'artist')]
    [OutputType('PowerLFM.Artist.Info')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
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
        $apiParams = [ordered] @{
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
        $hash = $irm | ConvertTo-Hashtable

        $similarArtists = foreach ($similar in $hash.Artist.Similar.Artist) {
            $similarInfo = [pscustomobject] @{
                'Artist' = $similar.Name
                'Url' = $similar.Url
            }
            $similarInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Similar')
            Write-Output $similarInfo
        }

        $tags = foreach ($tag in $hash.Artist.Tags.Tag) {
            $tagInfo = [pscustomobject] @{
                'Tag' = $tag.Name
                'Url' = $tag.Url
            }
            $tagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Tag')
            Write-Output $tagInfo
        }

        switch ($hash.Artist.OnTour) {
            '0' {$tour = 'No'}
            '1' {$tour = 'Yes'}
        }

        $artistInfo = [pscustomobject] @{
            'Artist' = $hash.Artist.Name
            'Id' = $hash.Artist.Mbid
            'Listeners' = [int] $hash.Artist.Stats.Listeners
            'PlayCount' = [int] $hash.Artist.Stats.PlayCount
            'OnTour' = $tour
            'Url' = $hash.Artist.Url
            'Summary' = $hash.Artist.Bio.Summary
            'SimilarArtists' = $similarArtists
            'Tags' = $tags
        }

        $userPlayCount = $hash.Artist.Stats.UserPlayCount
        if ($PSBoundParameters.ContainsKey('UserName')) {
            $artistInfo | Add-Member -MemberType NoteProperty -Name 'UserName' -Value $UserName
            $artistInfo | Add-Member -MemberType NoteProperty -Name 'UserPlayCount' -Value $userPlayCount
        }

        $artistInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Info')
        Write-Output $artistInfo
    }
}
