function Get-LFMScrobbleQueuePath {
    [CmdletBinding()]
    [OutputType('System.String')]
    param ()

    # The one seam every other scrobble queue function resolves its location through.
    #
    # $env:HOME rather than $HOME, which is the same directory by any ordinary route:
    # PowerShell sets $HOME from it at startup. The difference is that $HOME is read-only
    # and fixed for the life of the session, while the environment is what a process is
    # actually given - so this reads the environment on both platforms rather than one
    # each, and a session launched with a different home resolves its queue there.
    $root = if ($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) {
        $env:LOCALAPPDATA
    }
    else {
        Join-Path -Path $env:HOME -ChildPath '.local/share'
    }

    $directory = Join-Path -Path $root -ChildPath 'PowerLFM'
    Join-Path -Path $directory -ChildPath 'ScrobbleQueue.json'
}
