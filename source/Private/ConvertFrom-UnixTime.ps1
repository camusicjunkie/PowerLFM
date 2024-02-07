function ConvertFrom-UnixTime {
    [CmdletBinding()]
    [OutputType('System.DateTime')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [double] $UnixTime,

        [switch] $Local
    )

    $time = [DateTimeOffset]::FromUnixTimeSeconds($UnixTime)

    if ($PSBoundParameters.ContainsKey('Local')) {
        $time.LocalDateTime
    }
    else {
        $time.UtcDateTime
    }
}
