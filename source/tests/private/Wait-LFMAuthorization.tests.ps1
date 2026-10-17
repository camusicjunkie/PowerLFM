Describe 'Wait-LFMAuthorization: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    Context 'With a loopback listener' {

        BeforeAll {
            # Stands in for the user approving in the browser: Last.fm redirects to cb.
            Mock Open-LFMBrowser -ModuleName 'PowerLFM' {
                $cb = [uri]::UnescapeDataString(($Url.Query -split '&cb=')[1])
                $null = [System.Net.WebRequest]::Create("$cb`?token=abc").GetResponseAsync()
            }
            Mock Read-Host -ModuleName 'PowerLFM'
        }

        It 'Returns once the callback arrives, without prompting' {
            InModuleScope @module { Wait-LFMAuthorization -ApiKey 'Key' -Token 'abc' -TimeoutSeconds 30 }

            Should -Invoke Read-Host -ModuleName 'PowerLFM' -Times 0 -Exactly
        }

        It 'Opens the Last.fm authorization page with the key, token and a loopback callback' {
            InModuleScope @module { Wait-LFMAuthorization -ApiKey 'Key' -Token 'abc' -TimeoutSeconds 30 }

            Should -Invoke Open-LFMBrowser -ModuleName 'PowerLFM' -Times 1 -Exactly -ParameterFilter {
                $Url.AbsoluteUri -like 'https://www.last.fm/api/auth/?api_key=Key&token=abc&cb=http%3A%2F%2F127.0.0.1%3A*'
            }
        }
    }

    Context 'Without a listener' {

        BeforeAll {
            Mock Open-LFMAuthListener -ModuleName 'PowerLFM'
            Mock Open-LFMBrowser -ModuleName 'PowerLFM'
            Mock Read-Host -ModuleName 'PowerLFM'
        }

        It 'Prompts for Enter and sends no callback' {
            InModuleScope @module { Wait-LFMAuthorization -ApiKey 'Key' -Token 'abc' }

            Should -Invoke Read-Host -ModuleName 'PowerLFM' -Times 1 -Exactly
            Should -Invoke Open-LFMBrowser -ModuleName 'PowerLFM' -Times 1 -Exactly -ParameterFilter {
                $Url.AbsoluteUri -notmatch 'cb='
            }
        }
    }

    Context 'When no browser can be opened' {

        BeforeAll {
            Mock Open-LFMAuthListener -ModuleName 'PowerLFM'
            Mock Open-LFMBrowser -ModuleName 'PowerLFM' { throw 'no browser' }
            Mock Read-Host -ModuleName 'PowerLFM'
        }

        It 'Warns with the address and still prompts' {
            $warnings = InModuleScope @module {
                Wait-LFMAuthorization -ApiKey 'Key' -Token 'abc' 3>&1
            }

            "$warnings" | Should -Match 'https://www.last.fm/api/auth/\?api_key=Key&token=abc'
            Should -Invoke Read-Host -ModuleName 'PowerLFM' -Times 1 -Exactly
        }
    }

    Context 'When nobody approves in time' {

        BeforeAll {
            Mock Open-LFMBrowser -ModuleName 'PowerLFM'
            Mock Read-Host -ModuleName 'PowerLFM'
        }

        It 'Falls back to the prompt after the timeout' {
            InModuleScope @module { Wait-LFMAuthorization -ApiKey 'Key' -Token 'abc' -TimeoutSeconds 1 }

            Should -Invoke Read-Host -ModuleName 'PowerLFM' -Times 1 -Exactly
        }
    }
}
