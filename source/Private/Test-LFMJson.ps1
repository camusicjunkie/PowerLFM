function Test-LFMJson {
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string] $Json
    )

    process {
        # Answers "is this a JSON object", not "is this valid JSON". The one caller
        # reads properties off the result, so an array or a bare scalar is no more
        # use to it than a string that never parsed.
        #
        # Spelled out rather than as [pscustomobject], which is an accelerator for
        # PSObject and so matches every parsed value, scalars included.
        try {
            $parsed = ConvertFrom-Json -InputObject $Json -ErrorAction Stop
            Write-Output ($parsed -is [System.Management.Automation.PSCustomObject])
        }
        catch {
            Write-Output $false
        }
    }
}
