Describe 'Get-LFMSessionKeyFingerprint: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }

        $originalConfig = InModuleScope @module { $script:LFMConfig }
    }

    AfterAll {
        InModuleScope @module -Parameters @{ Config = $originalConfig } {
            param ($Config)
            $script:LFMConfig = $Config
        }
    }

    It 'Never returns the session key itself' {
        $result = InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{ SessionKey = 'SessionKeyValue' }
            Get-LFMSessionKeyFingerprint
        }

        $result | Should -Not -BeNullOrEmpty
        $result | Should -Not -Match 'SessionKeyValue'
    }

    It 'Returns the same fingerprint for the same session key' {
        $first = InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{ SessionKey = 'SessionKeyValue' }
            Get-LFMSessionKeyFingerprint
        }
        $second = InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{ SessionKey = 'SessionKeyValue' }
            Get-LFMSessionKeyFingerprint
        }

        $first | Should -Be $second
    }

    It 'Returns a different fingerprint for a different session key' {
        $mine = InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{ SessionKey = 'SessionKeyValue' }
            Get-LFMSessionKeyFingerprint
        }
        $theirs = InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{ SessionKey = 'SomeoneElsesKey' }
            Get-LFMSessionKeyFingerprint
        }

        $mine | Should -Not -Be $theirs
    }

    It 'Throws when no configuration is loaded' {
        {
            InModuleScope @module {
                $script:LFMConfig = $null
                Get-LFMSessionKeyFingerprint
            }
        } | Should -Throw '*No configuration is loaded*'
    }
}
