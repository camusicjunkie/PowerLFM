function Get-LFMAlbumTopTag {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding(DefaultParameterSetName = 'album')]
    [OutputType('PowerLFM.Album.Tag')]
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
        [string] $Id,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'album.getTopTags'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'AutoCorrect' {$apiParams.Add('autocorrect', 1)}
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'album' {$apiParams.Add('album', $Album);
                     $apiParams.Add('artist', $Artist)}
            'id'    {$apiParams.Add('mbid', $Id)}
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

        foreach ($tag in $irm.TopTags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Tag'
                'Tag' = $tag.Name
                'Url' = $tag.Url
                'Match' = $tag.Count
            }

            Write-Output $tagInfo
        }
    }
}
