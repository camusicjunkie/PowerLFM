Describe 'Enter-LFMScrobbleQueueLock: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    BeforeEach {
        $queuePath = Join-Path -Path $TestDrive -ChildPath 'lock\ScrobbleQueue.json'
        Remove-Item -LiteralPath (Split-Path -Path $queuePath -Parent) -Recurse -Force -ErrorAction SilentlyContinue

        InModuleScope @module -Parameters @{ QueuePath = $queuePath } {
            param ($QueuePath)
            $script:testQueuePath = $QueuePath
        }
    }

    It 'Creates the queue directory on the way to the lock' {
        $lock = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Enter-LFMScrobbleQueueLock
        }

        try {
            Test-Path -LiteralPath (Split-Path -Path $queuePath -Parent) | Should -BeTrue
        }
        finally { $lock.Dispose() }
    }

    It 'Locks a file beside the queue rather than the queue itself' {
        $lock = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Enter-LFMScrobbleQueueLock
        }

        try {
            Test-Path -LiteralPath "$queuePath.lock" | Should -BeTrue
            Test-Path -LiteralPath $queuePath | Should -BeFalse
        }
        finally { $lock.Dispose() }
    }

    It 'Returns nothing when another session already holds the lock' {
        $null = New-Item -Path (Split-Path -Path $queuePath -Parent) -ItemType Directory -Force
        $held = [IO.File]::Open("$queuePath.lock", 'OpenOrCreate', 'ReadWrite', 'None')

        try {
            $lock = InModuleScope @module {
                Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
                Enter-LFMScrobbleQueueLock -TimeoutMilliseconds 100
            }

            $lock | Should -BeNullOrEmpty
        }
        finally { $held.Dispose() }
    }

    It 'Hands the lock to the next caller once it is released' {
        $first = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Enter-LFMScrobbleQueueLock
        }
        $first.Dispose()

        $second = InModuleScope @module {
            Mock Get-LFMScrobbleQueuePath { $script:testQueuePath }
            Enter-LFMScrobbleQueueLock -TimeoutMilliseconds 100
        }

        try {
            $second | Should -Not -BeNullOrEmpty
        }
        finally { $second.Dispose() }
    }
}
