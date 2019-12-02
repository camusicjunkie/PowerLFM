function Test-Json {
    param (
        [string] $Json
    )

    $result = $true

    try {
        [Newtonsoft.Json.Linq.JObject]::Parse($Json)
    }
    catch {
        $result = $false
    }

    Write-Verbose $result
}
