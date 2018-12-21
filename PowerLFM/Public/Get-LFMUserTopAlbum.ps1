function Get-LFMUserTopAlbum {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.TopAlbum')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $UserName,

        [Parameter()]
        [ValidateSet('Overall', '7 Days', '1 Month',
                     '3 Months', '6 Months', '1 Year')]
        [string] $TimePeriod,

        [Parameter()]
        [ValidateRange(1,50)]
        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = [ordered] @{
            'method' = 'user.getTopAlbums'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        $period = @{
            'Overall' = 'Overall'
            '7 Days' = '7days'
            '1 Month' = '1month'
            '3 Months' = '3month'
            '6 Months' = '6month'
            '1 Year' = '12month'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
            'TimePeriod' {$apiParams.add('period', $period[$TimePeriod].ToLower())}
        }
    }
    process {
        switch ($PSBoundParameters.Keys) {
            'UserName' {$apiParams.add('user', $UserName)}
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

        foreach ($album in $hash.TopAlbums.Album) {
            $albumInfo = [pscustomobject] @{
                'Album' = $album.Name
                'PlayCount' = [int] $album.PlayCount
                'AlbumUrl' = $album.Url
                'Albumid' = $album.Mbid
                'Artist' = $album.Artist.Name
                'ArtistUrl' = $album.Artist.url
                'ArtistId' = $album.Artist.Mbid
                'ImageUrl' = $album.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            $albumInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.User.Album')
            Write-Output $albumInfo
        }
    }
}
