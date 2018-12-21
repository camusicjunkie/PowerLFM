function Get-LFMTrackTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'track')]
    [OutputType('PowerLFM.Track.UserTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'track')]
        [string] $Track,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'track')]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,
        [string] $UserName,
        [switch] $AutoCorrect
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'track.getTags'
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'track' {$apiParams.add('track', $Track);
                     $apiParams.add('artist', $Artist)}
            'id' {$apiParams.add('mbid', $Id)}
        }

        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.add('user', $UserName)
            $apiParams.add('api_key', $LFMConfig.APIKey)
        }
        else {
            $apiParams.add('api_key', $LFMConfig.APIKey)
            $apiParams.add('sk', $LFMConfig.SessionKey)
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

        $tags = foreach ($tag in $hash.Tags.Tag) {
            $tagInfo = [pscustomobject] @{
                'Tag' = $tag.Name
                'Url' = $tag.Url
            }
            $tagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Track.Tag')
            Write-Output $tagInfo
        }

        $trackTagInfo = [pscustomobject] @{
            'Artist' = $hash.Tags.'@attr'.Artist
            'Track' = $hash.Tags.'@attr'.Track
            'Tags' = $tags
        }

        if ($PSBoundParameters.ContainsKey('UserName')) {
            $trackTagInfo | Add-Member -MemberType NoteProperty -Name 'UserName' -Value $UserName
        }

        $trackTagInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Track.UserTag')
        Write-Output $trackTagInfo
    }
}