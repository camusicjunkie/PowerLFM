function Get-LFMAlbumTag {
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

        [string] $UserName,

        [switch] $AutoCorrect
    )

    begin {
        $apiParams = @{
            'method' = 'album.getTags'
            'api_key' = $LFMConfig.APIKey
            'sk' = $LFMConfig.SessionKey
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

        if ($PSBoundParameters.ContainsKey('UserName')) {
            $apiParams.Remove('sk')
            $apiParams.Add('user', $UserName)
        }

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        $irm = Invoke-LFMApiUri -Uri $apiUrl
        if ($irm.Error) {Write-Output $irm; return}

        foreach ($tag in $irm.Tags.Tag) {
            $tagInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Album.Tag'
                'Tag' = $tag.Name
                'Url' = [uri] $tag.Url
            }

            Write-Output $tagInfo
        }
    }
}
