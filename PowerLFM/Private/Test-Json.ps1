function Test-Json {
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string] $Json
    )

    $result = $true

    try {
        $null = [Newtonsoft.Json.Linq.JObject]::Parse($Json)
    }
    catch {
        $result = $false
    }

    Write-Output $result
}
