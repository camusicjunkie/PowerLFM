function ConvertTo-LFMParameter {
    [CmdletBinding()]
    param (
        [psobject] $InputObject,

        # Names come from the tables in prefix.ps1 and values are converted by type. See ADR-0008.
        [Parameter(Mandatory)]
        [string] $Method
    )

    $rename = $lfmMethod[$Method].Rename
    $ignored = [PSCmdlet]::CommonParameters + [PSCmdlet]::OptionalCommonParameters + 'PassThru'

    $hash = @{ }
    foreach ($key in $InputObject.Keys) {
        if ($key -in $ignored) { continue }

        $name = if ($rename -and $rename.ContainsKey($key)) { $rename[$key] } else { $lfmParameterName[$key] }

        # Dropping an unknown name would send the request without it, and nothing would
        # notice until Last.fm ignored or misread the request.
        if (-not $name) {
            $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
                [ArgumentException]::new(($localizedData.errorUnknownParameter -f $key, $Method)),
                'PowerLFM.UnknownParameter',
                'InvalidArgument',
                $key
            ))
        }

        $value = $InputObject[$key]
        # By type, so a new parameter of a known type is right without touching this.
        # TimePeriod is the one value Last.fm spells differently by name.
        $hash[$name] = if ($key -eq 'TimePeriod') { $lfmTimePeriod[$value] }
            elseif ($value -is [datetime]) { ConvertTo-UnixTime -Date $value }
            elseif ($value -is [switch] -or $value -is [bool]) { [int] [bool] $value }
            elseif ($value -is [guid]) { $value.ToString() }
            elseif ($value -is [array]) { $value -join ',' }
            else { $value }
    }

    return $hash
}
