function Get-LFMLibraryArtist {
    # .ExternalHelp PowerLFM.psm1-help.xml

    [CmdletBinding()]
    [OutputType('PowerLFM.Library.Artist')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [string] $Limit,

        [string] $Page
    )

    begin {
        $apiParams = @{
            'method' = 'library.getArtists'
            'api_key' = $LFMConfig.APIKey
            'format' = 'json'
        }

        switch ($PSBoundParameters.Keys) {
            'Limit' {$apiParams.add('limit', $Limit)}
            'Page' {$apiParams.add('page', $Page)}
        }
    }
    process {
        $apiParams.add('user', $UserName)

        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    end {
        try {
            $irm = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
        }
        catch {
            $response = $_.errorDetails.message | ConvertFrom-Json

            [pscustomobject] @{
                'Error' = $response.error
                'Message' = $response.message
            }
            return
        }

        foreach ($artist in $irm.Artists.Artist) {
            $artistInfo = [pscustomobject] @{
                'PSTypeName' = 'PowerLFM.Library.Artist'
                'Artist' = $artist.Name
                'PlayCount' = [int] $artist.PlayCount
                'Url' = $artist.url
                'Id' = $artist.Mbid
                'ImageUrl' = $artist.Image.Where({$_.Size -eq 'ExtraLarge'}).'#text'
            }

            Write-Output $artistInfo
        }
    }
}
