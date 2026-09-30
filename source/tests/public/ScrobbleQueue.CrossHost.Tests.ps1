Describe 'Scrobble queue: Cross host' -Tag Integration {

    # The Scrobble Queue outlives the session that wrote it, and nothing says the next
    # session is running the same host. Windows PowerShell and PowerShell 7 disagree about
    # what an unmarked text file is: 5.1 reads one with no byte order mark as ANSI, which
    # mangles every artist name outside ASCII. Export and Import each name UTF-8 by hand
    # because of it, and until now that reasoning lived only in a comment beside the code.
    #
    # Deliberately kept apart from the concurrency tests, which spawn processes for an
    # unrelated reason: a failure here should mean the two hosts disagree about encoding,
    # never that they disagreed about a lock.

    # Both hosts exist only on Windows, which is the only place the disagreement can
    # happen: there is no Windows PowerShell to disagree with anywhere else. Off Windows
    # SystemRoot is not set at all, so this resolves to nothing rather than failing.
    $windowsPowerShell = if ($env:SystemRoot) {
        Join-Path -Path $env:SystemRoot -ChildPath 'System32\WindowsPowerShell\v1.0\powershell.exe'
    }
    $pwsh = (Get-Command -Name 'pwsh' -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1).Source

    $bothHostsPresent = -not [string]::IsNullOrEmpty($windowsPowerShell) -and
                        -not [string]::IsNullOrEmpty($pwsh) -and
                        (Test-Path -LiteralPath $windowsPowerShell)

    BeforeAll {
        $windowsPowerShell = if ($env:SystemRoot) {
            Join-Path -Path $env:SystemRoot -ChildPath 'System32\WindowsPowerShell\v1.0\powershell.exe'
        }
        $pwsh = (Get-Command -Name 'pwsh' -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -First 1).Source

        $builtModule = (Get-Module -Name 'PowerLFM').Path

        # A name that is the whole point: every character outside ASCII here is one 5.1
        # would mangle if the encoding were left to the host to guess.
        $artist = "Sigur R$([char] 0xF3)s"
        $track = "Hopp$([char] 0xED)polla"

        $childScript = Join-Path -Path $TestDrive -ChildPath 'RoundTrip.ps1'
        Set-Content -LiteralPath $childScript -Encoding utf8 -Value @'
param ($ModulePath, $QueueRoot, $Work, $OutputPath)

$ErrorActionPreference = 'Stop'

trap {
    $_ | Out-String | Set-Content -LiteralPath (Join-Path $QueueRoot 'child-error.txt')
    exit 1
}

# The queue resolves through the environment, so redirecting it is all it takes to keep
# a test run away from the queue the user is actually keeping.
$env:LOCALAPPDATA = $QueueRoot
$env:HOME = $QueueRoot

Import-Module -Name $ModulePath -Force
$powerLFM = Get-Module -Name 'PowerLFM'

switch ($Work) {
    'Write' {
        & $powerLFM {
            param ($Artist, $Track)

            Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                Scrobbles = @(
                    [pscustomobject] @{
                        Artist                = $Artist
                        Track                 = $Track
                        Timestamp             = 1790596800
                        SessionKeyFingerprint = 'fingerprint'
                    }
                )
            })
        } $env:POWERLFM_TEST_ARTIST $env:POWERLFM_TEST_TRACK
    }

    'Read' {
        $queue = & $powerLFM { Import-LFMScrobbleQueue }
        $scrobble = @($queue.Scrobbles)[0]

        # Written back out as UTF-8 with no byte order mark for the same reason the queue
        # is: the parent may be the other host again.
        [IO.File]::WriteAllText(
            $OutputPath,
            ('{0}|{1}' -f $scrobble.Artist, $scrobble.Track),
            [Text.UTF8Encoding]::new($false)
        )
    }
}
'@

        function Invoke-Host {
            param ([string] $HostPath, [string] $Work, [string] $QueueRoot, [string] $OutputPath)

            $restoreArtist = $env:POWERLFM_TEST_ARTIST
            $restoreTrack = $env:POWERLFM_TEST_TRACK
            $env:POWERLFM_TEST_ARTIST = $artist
            $env:POWERLFM_TEST_TRACK = $track

            try {
                $argumentList = @(
                    '-NoProfile', '-NonInteractive', '-File', $childScript
                    '-ModulePath', $builtModule
                    '-QueueRoot', $QueueRoot
                    '-Work', $Work
                )
                if ($OutputPath) { $argumentList += @('-OutputPath', $OutputPath) }

                $process = Start-Process -FilePath $HostPath -ArgumentList $argumentList `
                    -PassThru -WindowStyle Hidden

                if (-not $process.WaitForExit(60000)) {
                    $process.Kill()
                    throw "The $HostPath child did not exit within 60 seconds."
                }

                if ($process.ExitCode -ne 0) {
                    $errorPath = Join-Path -Path $QueueRoot -ChildPath 'child-error.txt'
                    $reason = if (Test-Path -LiteralPath $errorPath) {
                        Get-Content -LiteralPath $errorPath -Raw
                    }
                    else { 'it left no error behind' }

                    throw "The $HostPath child exited with $($process.ExitCode): $reason"
                }
            }
            finally {
                $env:POWERLFM_TEST_ARTIST = $restoreArtist
                $env:POWERLFM_TEST_TRACK = $restoreTrack
            }
        }
    }

    It 'Reads back what the other host wrote, name for name (<Writer> writes, <Reader> reads)' -Skip:(-not $bothHostsPresent) -ForEach @(
        @{ Writer = 'Windows PowerShell'; Reader = 'PowerShell 7' }
        @{ Writer = 'PowerShell 7'; Reader = 'Windows PowerShell' }
    ) {
        $hostFor = @{
            'Windows PowerShell' = $windowsPowerShell
            'PowerShell 7'       = $pwsh
        }

        $queueRoot = Join-Path -Path $TestDrive -ChildPath ([guid]::NewGuid())
        $null = New-Item -Path $queueRoot -ItemType Directory -Force
        $readBack = Join-Path -Path $queueRoot -ChildPath 'read-back.txt'

        Invoke-Host -HostPath $hostFor[$Writer] -Work 'Write' -QueueRoot $queueRoot
        Invoke-Host -HostPath $hostFor[$Reader] -Work 'Read' -QueueRoot $queueRoot -OutputPath $readBack

        $roundTripped = [IO.File]::ReadAllText($readBack)
        $roundTripped | Should -Be ('{0}|{1}' -f $artist, $track)
    }

    It 'Writes the queue without a byte order mark for the other host to read' -Skip:(-not $bothHostsPresent) {
        $queueRoot = Join-Path -Path $TestDrive -ChildPath ([guid]::NewGuid())
        $null = New-Item -Path $queueRoot -ItemType Directory -Force

        Invoke-Host -HostPath $windowsPowerShell -Work 'Write' -QueueRoot $queueRoot

        # The mark is what 5.1 would add if the queue were written through Set-Content,
        # and what makes a file this module wrote unreadable to a parser expecting none.
        $queuePath = Join-Path -Path $queueRoot -ChildPath 'PowerLFM' |
            Join-Path -ChildPath 'ScrobbleQueue.json'
        $firstBytes = [IO.File]::ReadAllBytes($queuePath) | Select-Object -First 3

        ($firstBytes -join ',') | Should -Not -Be '239,187,191'
    }
}
