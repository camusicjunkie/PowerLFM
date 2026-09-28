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

    It 'Returns the same path every time it is asked' {
        $first = InModuleScope @module { Get-LFMScrobbleQueuePath }
        $second = InModuleScope @module { Get-LFMScrobbleQueuePath }

        $first | Should -Be $second
    }
}
