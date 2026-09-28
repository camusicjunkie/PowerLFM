Describe 'Send-LFMScrobbleBatch: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }

        $originalConfig = InModuleScope @module { $script:LFMConfig }

        InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{
                ApiKey       = 'ApiKeyValue'
                SessionKey   = 'SessionKeyValue'
                SharedSecret = 'SharedSecretValue'
            }
        }

        $twoScrobbles = @(
            [pscustomobject] @{
                Artist      = 'Opeth'
                Album       = 'Damnation'
                Track       = 'Windowpane'
                Timestamp   = 1790596800
                TrackNumber = 1
                Duration    = 469
                Id          = $null
            }
            [pscustomobject] @{
                Artist      = 'Katatonia'
                Album       = $null
                Track       = 'Ghost Of The Sun'
                Timestamp   = 1790597100
                TrackNumber = $null
                Duration    = $null
                Id          = $null
            }
        )
    }

    AfterAll {
        InModuleScope @module -Parameters @{ Config = $originalConfig } {
            param ($Config)
            $script:LFMConfig = $Config
        }
    }

    Context 'Request' {

        It 'Numbers every scrobble in the batch' {
            $uri = InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                Mock Invoke-LFMApiUri { $script:capturedUri = $Uri }
                $null = Send-LFMScrobbleBatch -Scrobble $Scrobbles
                $script:capturedUri
            }

            $uri | Should -Match 'artist\[0\]=Opeth'
            $uri | Should -Match 'track\[0\]=Windowpane'
            $uri | Should -Match 'timestamp\[0\]=1790596800'
            $uri | Should -Match 'artist\[1\]=Katatonia'
            $uri | Should -Match 'timestamp\[1\]=1790597100'
        }

        It 'Sends the optional details only for the scrobbles that have them' {
            $uri = InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                Mock Invoke-LFMApiUri { $script:capturedUri = $Uri }
                $null = Send-LFMScrobbleBatch -Scrobble $Scrobbles
                $script:capturedUri
            }

            $uri | Should -Match 'album\[0\]=Damnation'
            $uri | Should -Match 'duration\[0\]=469'
            $uri | Should -Not -Match 'album\[1\]'
            $uri | Should -Not -Match 'duration\[1\]'
        }

        It 'Signs the batch' {
            $uri = InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                Mock Invoke-LFMApiUri { $script:capturedUri = $Uri }
                $null = Send-LFMScrobbleBatch -Scrobble $Scrobbles
                $script:capturedUri
            }

            $uri | Should -Match 'api_sig=[0-9A-F]{32}'
        }

        It 'Never puts the shared secret on the wire' {
            $uri = InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                Mock Invoke-LFMApiUri { $script:capturedUri = $Uri }
                $null = Send-LFMScrobbleBatch -Scrobble $Scrobbles
                $script:capturedUri
            }

            $uri | Should -Not -Match 'SharedSecretValue'
        }

        It 'Calls the scrobble method over POST' {
            InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                Mock Invoke-LFMApiUri { }
                $null = Send-LFMScrobbleBatch -Scrobble $Scrobbles

                $siParams = @{
                    CommandName     = 'Invoke-LFMApiUri'
                    Exactly         = $true
                    Times           = 1
                    ParameterFilter = {
                        $Method -eq 'Post' -and
                        $Uri -match 'method=track\.scrobble'
                    }
                }
                Should -Invoke @siParams
            }
        }
    }

    Context 'Signature' {

        It 'Signs parameter names in the order Last.fm sorts them' {
            $signature = InModuleScope @module {
                New-LFMApiQuery -InputObject @{
                    'artist[10]' = 'Ten'
                    'artist[2]'  = 'Two'
                } -Signature
            }

            $signature | Should -Be 'artist[10]Tenartist[2]Two'
        }
    }

    Context 'Output' {

        It 'Outputs one result per submitted scrobble' {
            $results = InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                Mock Invoke-LFMApiUri {
                    [pscustomobject] @{
                        Scrobbles = [pscustomobject] @{
                            Scrobble = @(
                                [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 0 } }
                                [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 3 } }
                            )
                        }
                    }
                }
                Send-LFMScrobbleBatch -Scrobble $Scrobbles
            }

            @($results).Count | Should -Be 2
            $results[1].IgnoredMessage.Code | Should -Be 3
        }

        It 'Outputs a single result as a collection' {
            $results = InModuleScope @module -Parameters @{ Scrobbles = $twoScrobbles } {
                param ($Scrobbles)
                Mock Invoke-LFMApiUri {
                    [pscustomobject] @{
                        Scrobbles = [pscustomobject] @{
                            Scrobble = [pscustomobject] @{ IgnoredMessage = [pscustomobject] @{ Code = 0 } }
                        }
                    }
                }
                Send-LFMScrobbleBatch -Scrobble $Scrobbles
            }

            @($results).Count | Should -Be 1
        }
    }
}
