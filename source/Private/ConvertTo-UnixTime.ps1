function ConvertTo-UnixTime {
    [CmdletBinding()]
    [OutputType('System.TimeSpan')]
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
