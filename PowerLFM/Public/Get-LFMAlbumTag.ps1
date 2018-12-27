function Get-LFMAlbumTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'album')]
    [OutputType('PowerLFM.Album.UserTag')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'album')]
        [string] $Album,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'album')]
        [string] $Artist,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'id')]
        [string] $Id,

        [string] $UserName,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'album.getTags'
            'format' = 'json'
            'api_key' = $LFMConfig.APIKey
        }

        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.add('autocorrect', 1)}
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'album' {$apiParams.add('album', $Album);
                     $apiParams.add('artist', $Artist)}
            'id'    {$apiParams.add('mbid', $Id)}
        }

        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.add('user', $UserName)
        }
        else {
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

        foreach ($tag in $irm.Tags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Tag'
                'Tag' = $tag.Name
                'Url' = $tag.Url
            }

            Write-Output $tagInfo
        }
    }
}
