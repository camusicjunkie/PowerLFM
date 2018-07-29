function ConvertFrom-UnixTime {
    [CmdletBinding()]
    [OutputType('System.DateTime')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [double] $UnixTime,

        [switch] $Local
    )

    begin {
        [datetime] $epoch = '1/1/1970 00:00:00'
        $utcOffset = Get-Date -UFormat %Z
    }
    process {
        $time = $epoch.AddSeconds($UnixTime)

        if ($PSBoundParameters.ContainsKey('Local')) {
            Write-Output $time.AddHours($utcOffset)
        }
        else {
            Write-Output $time
        }
    }
}
