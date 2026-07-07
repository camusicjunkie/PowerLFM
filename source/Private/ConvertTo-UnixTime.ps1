function ConvertTo-UnixTime {
    [CmdletBinding()]
    [OutputType('System.Int64')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [datetime] $Date
    )

    if ($Date.Kind -eq 'Local') {
        ([DateTimeOffset] $Date).ToUniversalTime().ToUnixTimeSeconds()
    }
    else {
        ([DateTimeOffset] $Date).ToUnixTimeSeconds()
    }
}
