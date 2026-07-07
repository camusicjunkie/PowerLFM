function Test-LFMJson {
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string] $Json
    )

    process {
        $result = $true

        try {
            $null = ConvertFrom-Json -InputObject $Json -ErrorAction Stop
        }
        catch {
            $result = $false
        }

        $result
    }
}
