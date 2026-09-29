function Export-LFMScrobbleQueue {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [psobject] $Queue
    )

    # Only the Pending Scrobbles are read off the queue handed over: the version is this
    # module's to stamp, not the caller's to choose. The gate on an unrecognised version is
    # on the read side, where one can actually arrive - Import refuses or migrates a foreign
    # version before any write is reached (ADR-0006), so a queue this module does not
    # understand is never written over blindly.
    $path = Get-LFMScrobbleQueuePath
    $directory = Split-Path -Path $path -Parent
    if (-not (Test-Path -LiteralPath $directory)) {
        $null = New-Item -Path $directory -ItemType Directory -Force
    }

    $json = [pscustomobject] @{
        Version   = $scrobbleQueueVersion
        Scrobbles = @($Queue.Scrobbles)
    } | ConvertTo-Json -Depth 5

    # Written to one side and swapped in, so an interrupted write cannot leave a
    # half-serialised queue behind.
    #
    # WriteAllText rather than Set-Content: -Encoding utf8 writes a byte order mark on
    # 5.1 and none on 7, and a queue written by one host has to be readable by the
    # other. Artist names are not ASCII.
    $temporaryPath = '{0}.tmp' -f $path
    [IO.File]::WriteAllText($temporaryPath, $json, [Text.UTF8Encoding]::new($false))

    if (Test-Path -LiteralPath $path) {
        # [NullString]::Value, not $null: PowerShell passes $null to a .NET string
        # parameter as an empty string, and Replace rejects that as a backup path.
        [IO.File]::Replace($temporaryPath, $path, [NullString]::Value)
    }
    else {
        [IO.File]::Move($temporaryPath, $path)
    }
}
