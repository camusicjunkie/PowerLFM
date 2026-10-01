Describe 'Get-LFMScrobbleQueuePath: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    It 'Names the queue file inside a PowerLFM directory' {
        $result = InModuleScope @module { Get-LFMScrobbleQueuePath }

        Split-Path -Path $result -Leaf | Should -Be 'ScrobbleQueue.json'
        Split-Path -Path (Split-Path -Path $result -Parent) -Leaf | Should -Be 'PowerLFM'
    }

    It 'Resolves to local application data on Windows' -Skip:($PSVersionTable.PSVersion.Major -ge 6 -and -not $IsWindows) {
        $result = InModuleScope @module { Get-LFMScrobbleQueuePath }

        $result | Should -BeLike "$env:LOCALAPPDATA*"
    }

    It 'Resolves under the home directory off Windows' -Skip:($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) {
        $result = InModuleScope @module { Get-LFMScrobbleQueuePath }

        $result | Should -BeLike (Join-Path -Path $env:HOME -ChildPath '.local/share*')
    }

    It 'Follows the home the session was given rather than the one it started with' -Skip:($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) {
        # $HOME is read-only and fixed when the session starts, so a path resolved through
        # it cannot be pointed anywhere - not by a caller, and not by a test. Reading the
        # environment is what lets a process be told where its home is, which is how the
        # concurrency tests give a child a queue of its own instead of writing into the
        # queue the user is keeping.
        $restore = $env:HOME

        try {
            $env:HOME = '/tmp/powerlfm-test-home'
            $result = InModuleScope @module { Get-LFMScrobbleQueuePath }

            $result | Should -BeLike '/tmp/powerlfm-test-home*'
        }
        finally { $env:HOME = $restore }
    }

    It 'Returns the same path every time it is asked' {
        $first = InModuleScope @module { Get-LFMScrobbleQueuePath }
        $second = InModuleScope @module { Get-LFMScrobbleQueuePath }

        $first | Should -Be $second
    }
}
