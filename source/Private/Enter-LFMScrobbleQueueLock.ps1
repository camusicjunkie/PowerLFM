function Enter-LFMScrobbleQueueLock {
    [CmdletBinding()]
    [OutputType('System.IO.FileStream')]
    param (
        [int] $TimeoutMilliseconds = 2000
    )

    # An exclusive handle on a sidecar file, held for the whole read-modify-write. The
    # queue file itself cannot be used: it is swapped out by rename on every write.
    $path = '{0}.lock' -f (Get-LFMScrobbleQueuePath)
    $directory = Split-Path -Path $path -Parent
    if (-not (Test-Path -LiteralPath $directory)) {
        $null = New-Item -Path $directory -ItemType Directory -Force
    }

    $stopwatch = [Diagnostics.Stopwatch]::StartNew()
    do {
        try {
            return [IO.File]::Open($path, 'OpenOrCreate', 'ReadWrite', 'None')
        }
        catch [IO.IOException] {
            Start-Sleep -Milliseconds 50
        }
    }
    while ($stopwatch.ElapsedMilliseconds -lt $TimeoutMilliseconds)

    # Nothing is returned on timeout. Callers decide what that means: an append warns
    # and lets the scrobble throw, a flush leaves the work to whoever holds the lock.
}
