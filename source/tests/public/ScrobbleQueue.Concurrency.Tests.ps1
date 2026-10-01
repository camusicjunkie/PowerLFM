Describe 'Scrobble queue: Concurrency' -Tag Concurrency {

    # The Scrobble Queue outlives the session that wrote it and is shared by every session
    # on the machine, so its two load-bearing claims - that a Queue Update is an exclusive
    # hold, and that reading takes no hold - are claims about separate operating system
    # processes. Every other test in this suite fakes the rival session in process, where
    # one .NET handle contends with another inside the same file sharing table. These
    # spawn a real one.
    #
    # Children are pointed at a queue of their own by redirecting the environment they
    # resolve the path from, never by a switch or a variable this module ships. That way
    # Get-LFMScrobbleQueuePath itself is under test, including the branch that only runs
    # off Windows, and a test run cannot touch the queue the user is actually keeping.
    #
    # Nothing here sleeps to arrange a race. Children announce what they hold by creating
    # a barrier file and wait for one before they let go, so an assertion is made while
    # the state it describes provably holds rather than shortly after it probably does.

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }

        # The same host the suite is running on: these tests are about locking and
        # lifetime, not about the two hosts agreeing. That claim is tested separately.
        $hostPath = (Get-Process -Id $PID).Path
        $builtModule = (Get-Module -Name 'PowerLFM').Path

        $scriptRoot = Join-Path -Path $TestDrive -ChildPath 'children'
        $null = New-Item -Path $scriptRoot -ItemType Directory -Force

        # Holds an exclusive handle on the lock file with no PowerLFM in sight, so what it
        # proves is that the operating system excludes a second process - not that this
        # module's own bookkeeping excludes a second call.
        $lockHolderScript = Join-Path -Path $scriptRoot -ChildPath 'HoldLock.ps1'
        Set-Content -LiteralPath $lockHolderScript -Encoding utf8 -Value @'
param ($LockPath, $HoldingFlag, $ReleaseFlag)

$directory = Split-Path -Path $LockPath -Parent
if (-not (Test-Path -LiteralPath $directory)) {
    $null = New-Item -Path $directory -ItemType Directory -Force
}

$lock = [IO.File]::Open($LockPath, 'OpenOrCreate', 'ReadWrite', 'None')
$null = New-Item -Path $HoldingFlag -ItemType File -Force

# Bounded so a parent that dies cannot leave this process holding the lock forever.
$deadline = [datetime]::UtcNow.AddSeconds(60)
while (-not (Test-Path -LiteralPath $ReleaseFlag) -and [datetime]::UtcNow -lt $deadline) {
    Start-Sleep -Milliseconds 25
}

$lock.Dispose()
'@

        # Runs real PowerLFM commands against a queue of its own. Offline is arranged by
        # defining Invoke-RestMethod inside the module's own scope: a function there wins
        # over the cmdlet for every call the module makes, which is the same seam the
        # mocked tests use, reached without Pester in the child.
        $moduleChildScript = Join-Path -Path $scriptRoot -ChildPath 'RunModule.ps1'
        Set-Content -LiteralPath $moduleChildScript -Encoding utf8 -Value @'
param ($ModulePath, $QueueRoot, $Work, $HoldingFlag, $ReleaseFlag, $StartFlag)

# Anything that goes wrong in here is a test failure, and a child that dies quietly makes
# it one the parent can only report as an exit code. Stop on everything, and leave the
# reason on disk next to the queue for the parent to read back.
$ErrorActionPreference = 'Stop'

trap {
    $_ | Out-String | Set-Content -LiteralPath (Join-Path $QueueRoot 'child-error.txt')
    exit 1
}

# The redirection, and the whole of it: both names, because the queue path resolves
# through LOCALAPPDATA on Windows and HOME everywhere else.
$env:LOCALAPPDATA = $QueueRoot
$env:HOME = $QueueRoot

Import-Module -Name $ModulePath -Force

$powerLFM = Get-Module -Name 'PowerLFM'

& $powerLFM {
    $script:LFMConfig = [pscustomobject] @{
        ApiKey       = 'ApiKeyValue'
        SessionKey   = 'SessionKeyValue'
        SharedSecret = 'SharedSecretValue'
    }

    # script: matters. Without it the function lands in this scriptblock's own scope and
    # is gone by the time the module calls it - and the call goes to the real Last.fm.
    function script:Invoke-RestMethod {
        throw [Net.WebException]::new(
            'The remote name could not be resolved.',
            [Net.WebExceptionStatus]::NameResolutionFailure
        )
    }
}

function Wait-Flag ($Path) {
    $deadline = [datetime]::UtcNow.AddSeconds(60)
    while (-not (Test-Path -LiteralPath $Path) -and [datetime]::UtcNow -lt $deadline) {
        Start-Sleep -Milliseconds 25
    }
}

if ($StartFlag) { Wait-Flag $StartFlag }

switch ($Work) {
    'Scrobble' {
        Set-LFMTrackScrobble -Artist 'Opeth' -Track 'Windowpane' `
            -Timestamp ([datetime]::new(2026, 9, 28, 12, 0, 0, [DateTimeKind]::Local)) `
            -WarningAction SilentlyContinue
        Set-LFMTrackScrobble -Artist 'Opeth' -Track 'In My Time Of Need' `
            -Timestamp ([datetime]::new(2026, 9, 28, 12, 8, 0, [DateTimeKind]::Local)) `
            -WarningAction SilentlyContinue
    }

    'ScrobbleOne' {
        Set-LFMTrackScrobble -Artist $env:POWERLFM_TEST_ARTIST -Track $env:POWERLFM_TEST_TRACK `
            -Timestamp ([datetime]::new(2026, 9, 28, 12, 0, 0, [DateTimeKind]::Local)) `
            -WarningAction SilentlyContinue
    }

    'HoldTheQueue' {
        # The module's own hold, taken the way a Queue Update takes it.
        $lock = & $powerLFM { Enter-LFMScrobbleQueueLock }
        if ($null -eq $lock) { throw 'The child could not take the queue lock' }

        $null = New-Item -Path $HoldingFlag -ItemType File -Force
        Wait-Flag $ReleaseFlag
        $lock.Dispose()
    }

    'CommitRepeatedly' {
        $null = New-Item -Path $HoldingFlag -ItemType File -Force

        # Commits until told to stop. Any commit that throws leaves a non-zero exit code
        # behind, which is what the parent asserts on.
        while (-not (Test-Path -LiteralPath $ReleaseFlag)) {
            & $powerLFM {
                $null = Update-LFMScrobbleQueue -Change {
                    param ($Scrobbles, $Save)
                    & $Save @($Scrobbles)
                }
            }
        }
    }
}
'@

        function Start-Child {
            param ([string] $Script, [hashtable] $Arguments, [hashtable] $Environment)

            $argumentList = @('-NoProfile', '-NonInteractive', '-File', $Script)
            foreach ($name in $Arguments.Keys) {
                $argumentList += "-$name"
                $argumentList += $Arguments[$name]
            }

            $spParams = @{
                FilePath     = $hostPath
                ArgumentList = $argumentList
                PassThru     = $true
            }

            # Windows only: Start-Process refuses the parameter everywhere else.
            if ($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) {
                $spParams['WindowStyle'] = 'Hidden'
            }

            if ($Environment) {
                # Start-Process gives the child this process's environment, so a variable
                # meant only for the child is set, handed over and put back.
                $restore = @{}
                foreach ($name in $Environment.Keys) {
                    $restore[$name] = [Environment]::GetEnvironmentVariable($name)
                    Set-Item -Path "env:$name" -Value $Environment[$name]
                }

                try { Start-Process @spParams }
                finally {
                    foreach ($name in $restore.Keys) {
                        if ($null -eq $restore[$name]) {
                            Remove-Item -Path "env:$name" -ErrorAction SilentlyContinue
                        }
                        else {
                            Set-Item -Path "env:$name" -Value $restore[$name]
                        }
                    }
                }
            }
            else {
                Start-Process @spParams
            }
        }

        function Wait-Barrier {
            param ([string] $Path, [int] $TimeoutSeconds = 30)

            $deadline = [datetime]::UtcNow.AddSeconds($TimeoutSeconds)
            while (-not (Test-Path -LiteralPath $Path)) {
                if ([datetime]::UtcNow -ge $deadline) {
                    throw "Timed out after $TimeoutSeconds seconds waiting for the barrier file '$Path'. The child process never reached the state this test needs."
                }
                Start-Sleep -Milliseconds 25
            }
        }

        # A child that failed wrote why next to its queue. Without this an exit code is
        # all a CI log would show, and the reason would be on a machine that is gone.
        function Get-ChildError {
            param ([string] $QueueRoot)

            $path = Join-Path -Path $QueueRoot -ChildPath 'child-error.txt'
            if (Test-Path -LiteralPath $path) { Get-Content -LiteralPath $path -Raw }
            else { 'the child left no error behind' }
        }

        function Wait-Child {
            param ($Process, [int] $TimeoutSeconds = 60)

            if (-not $Process.WaitForExit($TimeoutSeconds * 1000)) {
                $Process.Kill()
                throw "The child process did not exit within $TimeoutSeconds seconds."
            }
        }
    }

    BeforeEach {
        # A root per test, and the queue underneath it exactly where the module resolves
        # it to, so parent and child are talking about the same file without the parent
        # having to be told where the child put it.
        $queueRoot = Join-Path -Path $TestDrive -ChildPath ([guid]::NewGuid())

        # Where the child will put its queue, worked out by asking the module rather than
        # by spelling the layout out here: the root is LOCALAPPDATA on Windows and HOME
        # everywhere else, and the path underneath it differs too. Spelling it out meant
        # the parent watched a file on Windows and the wrong one on Linux - where the
        # tests that only needed the two to meet then passed without them ever meeting.
        $queuePath = InModuleScope @module -Parameters @{ Root = $queueRoot } {
            param ($Root)

            $restore = @{
                LOCALAPPDATA = $env:LOCALAPPDATA
                HOME         = $env:HOME
            }

            try {
                $env:LOCALAPPDATA = $Root
                $env:HOME = $Root
                Get-LFMScrobbleQueuePath
            }
            finally {
                foreach ($name in $restore.Keys) {
                    if ($null -eq $restore[$name]) {
                        Remove-Item -Path "env:$name" -ErrorAction SilentlyContinue
                    }
                    else {
                        Set-Item -Path "env:$name" -Value $restore[$name]
                    }
                }
            }
        }

        $lockPath = "$queuePath.lock"
        $barriers = Join-Path -Path $queueRoot -ChildPath 'barriers'
        $null = New-Item -Path $barriers -ItemType Directory -Force

        $holdingFlag = Join-Path -Path $barriers -ChildPath 'holding'
        $releaseFlag = Join-Path -Path $barriers -ChildPath 'release'
        $startFlag = Join-Path -Path $barriers -ChildPath 'start'

        $children = [Collections.Generic.List[object]]::new()

        InModuleScope @module -Parameters @{ QueuePath = $queuePath } {
            param ($QueuePath)
            $script:testQueuePath = $QueuePath
        }
    }

    AfterEach {
        # A test that failed part way through may have left a child holding the lock on a
        # file the next test is about to be given. Nothing is left running.
        foreach ($child in $children) {
            if ($child -and -not $child.HasExited) {
                # It exiting between the check and the kill is the good outcome, and is
                # the only thing this is expected to throw about.
                try { $child.Kill() }
                catch { Write-Verbose "A child had already exited: $_" }
            }
        }
    }

    Context 'The hold across processes' {

        It 'Refuses the hold while another operating system process owns it' {
            $children.Add((Start-Child -Script $lockHolderScript -Arguments @{
                LockPath    = $lockPath
                HoldingFlag = $holdingFlag
                ReleaseFlag = $releaseFlag
            }))

            Wait-Barrier -Path $holdingFlag

            $contended = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Enter-LFMScrobbleQueueLock -TimeoutMilliseconds 300
            }

            $contended | Should -BeNullOrEmpty

            $null = New-Item -Path $releaseFlag -ItemType File -Force
            Wait-Child -Process $children[0]

            $granted = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Enter-LFMScrobbleQueueLock -TimeoutMilliseconds 2000
            }

            try { $granted | Should -Not -BeNullOrEmpty }
            finally { if ($granted) { $granted.Dispose() } }
        }

        It 'Takes the hold a killed session left behind' {
            $child = Start-Child -Script $lockHolderScript -Arguments @{
                LockPath    = $lockPath
                HoldingFlag = $holdingFlag
                ReleaseFlag = $releaseFlag
            }
            $children.Add($child)

            Wait-Barrier -Path $holdingFlag

            # Killed, not asked: the lock file is left behind with nobody to release it.
            $child.Kill()
            Wait-Child -Process $child

            $granted = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Enter-LFMScrobbleQueueLock -TimeoutMilliseconds 2000
            }

            try { $granted | Should -Not -BeNullOrEmpty }
            finally { if ($granted) { $granted.Dispose() } }
        }
    }

    Context 'Reading against a Queue Update' {

        It 'Reads the pending scrobbles while another session holds the queue' {
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                    Scrobbles = @(
                        [pscustomobject] @{
                            Artist                = 'Opeth'
                            Track                 = 'Windowpane'
                            Timestamp             = 1790596800
                            SessionKeyFingerprint = 'fingerprint'
                        }
                    )
                })
            }

            $children.Add((Start-Child -Script $moduleChildScript -Arguments @{
                ModulePath  = $builtModule
                QueueRoot   = $queueRoot
                Work        = 'HoldTheQueue'
                HoldingFlag = $holdingFlag
                ReleaseFlag = $releaseFlag
            }))

            Wait-Barrier -Path $holdingFlag

            # The hold is somebody else's and still held. Reading is not a Queue Update,
            # so it neither waits for it nor fails against it.
            $pending = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Get-LFMScrobbleQueue
            }

            @($pending).Count | Should -Be 1
            $pending[0].Track | Should -Be 'Windowpane'

            $null = New-Item -Path $releaseFlag -ItemType File -Force
            Wait-Child -Process $children[0]
        }

        It 'Commits a queue update while another session is reading the queue file' {
            # A read used to hold the queue file in a way that denied writers for as long
            # as it took, and a Queue Update commits by swapping the file in - which on
            # Windows fails outright against an open reader. So a session doing nothing
            # but reading could make another session's commit throw.
            #
            # This one races on purpose: the child commits in a loop while the parent
            # reads in a loop, and it fails only when a commit actually throws. It cannot
            # go red on timing alone - the worst a quiet machine can do is miss a defect,
            # never invent one.
            InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Export-LFMScrobbleQueue -Queue ([pscustomobject] @{
                    Scrobbles = @(
                        [pscustomobject] @{
                            Artist                = 'Opeth'
                            Track                 = 'Windowpane'
                            Timestamp             = 1790596800
                            SessionKeyFingerprint = 'fingerprint'
                        }
                    )
                })
            }

            $child = Start-Child -Script $moduleChildScript -Arguments @{
                ModulePath  = $builtModule
                QueueRoot   = $queueRoot
                Work        = 'CommitRepeatedly'
                HoldingFlag = $holdingFlag
                ReleaseFlag = $releaseFlag
            }
            $children.Add($child)

            Wait-Barrier -Path $holdingFlag

            $read = 0
            $deadline = [datetime]::UtcNow.AddSeconds(5)
            while ([datetime]::UtcNow -lt $deadline -and -not $child.HasExited) {
                $null = InModuleScope @module {
                    Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                    Import-LFMScrobbleQueue
                }
                $read++
            }

            $null = New-Item -Path $releaseFlag -ItemType File -Force
            Wait-Child -Process $child

            $read | Should -BeGreaterThan 0
            $child.ExitCode | Should -Be 0 -Because (
                'a session reading the queue must not stop another session committing to it. The child said: {0}' -f
                    (Get-ChildError -QueueRoot $queueRoot)
            )
        }
    }

    Context 'Outliving the session' {

        It 'Keeps the pending scrobbles a session queued after that session has exited' {
            $child = Start-Child -Script $moduleChildScript -Arguments @{
                ModulePath = $builtModule
                QueueRoot  = $queueRoot
                Work       = 'Scrobble'
            }
            $children.Add($child)

            Wait-Child -Process $child
            $child.ExitCode | Should -Be 0 -Because (Get-ChildError -QueueRoot $queueRoot)

            # Nothing of that session is left: it queued while Last.fm was unreachable,
            # and then it was gone.
            $pending = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Get-LFMScrobbleQueue
            }

            @($pending).Count | Should -Be 2
            $pending.Track | Should -Contain 'Windowpane'
            $pending.Track | Should -Contain 'In My Time Of Need'
        }

        It 'Queues both plays when two sessions scrobble at the same moment' {
            $first = Start-Child -Script $moduleChildScript -Environment @{
                POWERLFM_TEST_ARTIST = 'Opeth'
                POWERLFM_TEST_TRACK  = 'Windowpane'
            } -Arguments @{
                ModulePath = $builtModule
                QueueRoot  = $queueRoot
                Work       = 'ScrobbleOne'
                StartFlag  = $startFlag
            }
            $children.Add($first)

            $second = Start-Child -Script $moduleChildScript -Environment @{
                POWERLFM_TEST_ARTIST = 'Katatonia'
                POWERLFM_TEST_TRACK  = 'July'
            } -Arguments @{
                ModulePath = $builtModule
                QueueRoot  = $queueRoot
                Work       = 'ScrobbleOne'
                StartFlag  = $startFlag
            }
            $children.Add($second)

            # Both are up and waiting; this is what makes them race rather than queue up.
            $null = New-Item -Path $startFlag -ItemType File -Force

            Wait-Child -Process $first
            Wait-Child -Process $second
            $first.ExitCode | Should -Be 0 -Because (Get-ChildError -QueueRoot $queueRoot)
            $second.ExitCode | Should -Be 0 -Because (Get-ChildError -QueueRoot $queueRoot)

            $pending = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Get-LFMScrobbleQueue
            }

            @($pending).Count | Should -Be 2
            $pending.Track | Should -Contain 'Windowpane'
            $pending.Track | Should -Contain 'July'
        }
    }
}
