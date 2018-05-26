function ConvertTo-UnixTime {
    [CmdletBinding()]
    [OutputType('System.TimeSpan')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [datetime] $Date
    )

    begin {
        [datetime] $epoch = '1/1/1970 00:00:00'
    }
    process {
        if ($Date.Kind -eq 'Local') {
            $Date = $Date.ToUniversalTime()
        }
        
        (New-TimeSpan -Start $epoch -End $Date).TotalSeconds
    }
}