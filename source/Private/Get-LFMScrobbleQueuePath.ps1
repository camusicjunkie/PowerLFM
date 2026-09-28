function Get-LFMScrobbleQueuePath {
    [CmdletBinding()]
    [OutputType('System.String')]
    param ()

    # The one seam every other scrobble queue function resolves its location through.
    $root = if ($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) {
        $env:LOCALAPPDATA
    }
    else {
        Join-Path -Path $HOME -ChildPath '.local/share'
    }

    $directory = Join-Path -Path $root -ChildPath 'PowerLFM'
    Join-Path -Path $directory -ChildPath 'ScrobbleQueue.json'
}
