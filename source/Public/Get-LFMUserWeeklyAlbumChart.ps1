function Get-LFMUserWeeklyAlbumChart {
    # .ExternalHelp PowerLFM-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.User.WeeklyAlbumChart')]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime] $StartDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime] $EndDate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName
    )

    process {
        $irm = Invoke-LFMApiMethod -Method 'user.getWeeklyAlbumChart' -Parameter $PSBoundParameters

        foreach ($album in $irm.WeeklyAlbumChart.Album) {
            $albumInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.User.WeeklyChartList'
                'Album' = $album.Name
                'Url' = [uri] $album.Url
                'Id' = $album.Mbid
                'Artist' = $album.Artist.'#text'
                'ArtistId' = $album.Artist.Mbid
                'PlayCount' = [int] $album.PlayCount
                'StartDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyAlbumChart.'@attr'.From -Local
                'EndDate' = ConvertFrom-UnixTime -UnixTime $irm.WeeklyAlbumChart.'@attr'.To -Local
            }

            Write-Output $albumInfo
        }
    }
}
