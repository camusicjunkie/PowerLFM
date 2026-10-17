Describe 'Open-LFMAuthListener: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    It 'Listens on a loopback address only' {
        $listener = InModuleScope @module { Open-LFMAuthListener }

        try {
            $listener.IsListening | Should -BeTrue
            $listener.Prefixes | Should -BeLike 'http://127.0.0.1:*/'
        }
        finally {
            $listener.Close()
        }
    }
}
