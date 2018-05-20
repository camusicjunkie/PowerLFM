function Get-LFMArtistCorrection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string] $Artist
    )

    begin {
        #Default hashtable
        $apiParams = [ordered] @{
            'method' = 'album.getCorrection'
            'api_key' = $LFMConfig.APIKey
            'artist' = $Artist
            'format' = 'json'
        }
        #Building string to append to base url
        $keyValues = $apiParams.GetEnumerator() | ForEach-Object {
            "$($_.Name)=$($_.Value)"
        }
        $string = $keyValues -join '&'

        $apiUrl = "$baseUrl/?$string"
    }
    process {
        $iwr = Invoke-WebRequest -Uri $apiUrl
        $jsonString = $iwr.AllElements[3].innerHTML
        $hash = $jsonString | ConvertFrom-Json | ConvertTo-HashTable
        
        $correctedArtistInfo = [pscustomobject] @{
            'Artist' = $hash.Corrections.Correction.Artist.Name
            'Id' = $hash.Corrections.Correction.Artist.Mbid
            'Url' = $hash.Corrections.Correction.Artist.Url
        }

        $correctedArtistInfo.PSObject.TypeNames.Insert(0, 'PowerLFM.Artist.Corrected')
        Write-Output $correctedArtistInfo
    }
}