Describe 'Invoke-LFMApiMethod: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $module = @{ ModuleName = 'PowerLFM' }

        $originalConfig = InModuleScope @module { $script:LFMConfig }

        InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{
                ApiKey       = 'ApiKeyValue'
                SessionKey   = 'SessionKeyValue'
                SharedSecret = 'SharedSecretValue'
            }
        }
    }

    AfterAll {
        InModuleScope @module -Parameters @{ Config = $originalConfig } {
            param ($Config)
            $script:LFMConfig = $Config
        }
    }

    BeforeEach {
        Register-LFMFakeRestMethod
    }

    # Every expected api_sig below was worked out once, outside the module, as the MD5 of
    # the parameters sorted ordinally and written name then value, followed by the Shared
    # Secret. Never recompute one here: the same algorithm would agree with itself.
    Context 'A write' {

        BeforeEach {
            InModuleScope @module {
                $null = Invoke-LFMApiMethod -Method 'track.love' -Parameter @{
                    Artist = 'Opeth'
                    Track  = 'Windowpane'
                }
            }
            $request = Get-LFMRecordedRequest
        }

        It 'Is sent as a POST' {
            $request.HttpMethod | Should -Be 'Post'
        }

        It 'Carries the Method, the API Key and the Session Key' {
            $request.Method | Should -Be 'track.love'
            $request.Parameters['api_key'] | Should -Be 'ApiKeyValue'
            $request.Parameters['sk'] | Should -Be 'SessionKeyValue'
        }

        It 'Carries the parameters under Last.fm names' {
            $request.Parameters['artist'] | Should -BeExactly 'Opeth'
            $request.Parameters['track'] | Should -BeExactly 'Windowpane'
        }

        It 'Asks for JSON' {
            $request.Parameters['format'] | Should -Be 'json'
        }

        It 'Is signed' {
            # api_keyApiKeyValueartistOpethmethodtrack.loveskSessionKeyValuetrackWindowpaneSharedSecretValue
            $request.Parameters['api_sig'] | Should -Be '74417785728CFFFA79E972379F0397F5'
        }

        It 'Never puts the Shared Secret on the wire' {
            $request.Uri | Should -Not -Match 'SharedSecretValue'
        }
    }

    Context 'A read' {

        It 'Is an unsigned GET without the Session Key' {
            InModuleScope @module {
                $null = Invoke-LFMApiMethod -Method 'user.getInfo' -Parameter @{ UserName = 'someone' }
            }
            $request = Get-LFMRecordedRequest

            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters['api_key'] | Should -Be 'ApiKeyValue'
            $request.Parameters['format'] | Should -Be 'json'
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
        }
    }

    Context 'No Configuration' {

        BeforeEach {
            $loadedConfig = InModuleScope @module { $script:LFMConfig }
            InModuleScope @module { $script:LFMConfig = $null }
        }

        AfterEach {
            InModuleScope @module -Parameters @{ Config = $loadedConfig } {
                param ($Config)
                $script:LFMConfig = $Config
            }
        }

        It 'Throws before sending anything' {
            $err = {
                InModuleScope @module {
                    Invoke-LFMApiMethod -Method 'track.love' -Parameter @{ Artist = 'Opeth'; Track = 'Windowpane' }
                }
            } | Should -Throw -PassThru

            $err.FullyQualifiedErrorId | Should -BeLike 'PowerLFM.ConfigurationNotLoaded*'
            Get-LFMRecordedRequest | Should -BeNullOrEmpty
        }

        It 'Throws the same error as the Session Key Fingerprint' {
            $request = { InModuleScope @module { Invoke-LFMApiMethod -Method 'user.getInfo' -Parameter @{ UserName = 'someone' } } } |
                Should -Throw -PassThru
            $fingerprint = { InModuleScope @module { Get-LFMSessionKeyFingerprint } } | Should -Throw -PassThru

            $fingerprint.FullyQualifiedErrorId | Should -BeLike 'PowerLFM.ConfigurationNotLoaded*'
            $fingerprint.Exception.Message | Should -Be $request.Exception.Message
        }

        It 'Sends with explicit Credentials' {
            InModuleScope @module {
                $null = Invoke-LFMApiMethod -Method 'auth.getToken' -Credentials @{ ApiKey = 'AppKey'; SharedSecret = 'AppSecret' }
            }

            @(Get-LFMRecordedRequest).Count | Should -Be 1
        }
    }

    Context 'Verbose output' {

        BeforeEach {
            $streams = InModuleScope @module {
                Invoke-LFMApiMethod -Method 'track.love' -Parameter @{ Artist = 'Opeth'; Track = 'Windowpane' } -Verbose *>&1
            }
            $verbose = @($streams | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] })
        }

        It 'Writes one line naming the Method, the HTTP method and the parameters' {
            $verbose.Count | Should -Be 1
            $verbose[0].Message | Should -Match 'track\.love'
            $verbose[0].Message | Should -Match 'POST'
            $verbose[0].Message | Should -Match 'artist=Opeth'
            $verbose[0].Message | Should -Match 'track=Windowpane'
        }

        It 'Masks the Session Key and the Signature' {
            $verbose[0].Message | Should -Match 'sk=\*+'
            $verbose[0].Message | Should -Match 'api_sig=\*+'
            $verbose[0].Message | Should -Not -Match '74417785728CFFFA79E972379F0397F5'
        }

        It 'Never shows the Shared Secret or the Session Key in any stream' {
            ($streams | Out-String) | Should -Not -Match 'SharedSecretValue'
            ($streams | Out-String) | Should -Not -Match 'SessionKeyValue'
        }
    }

    Context 'A write with names outside ASCII' {

        It 'Is signed over the UTF-8 bytes' {
            # Built from code points so the test reads the same under any file encoding.
            $artist = "Sigur R$([char] 0x00F3)s"
            $track = "Hopp$([char] 0x00ED)polla"

            InModuleScope @module -Parameters @{ Artist = $artist; Track = $track } {
                param ($Artist, $Track)
                $null = Invoke-LFMApiMethod -Method 'track.love' -Parameter @{ Artist = $Artist; Track = $Track }
            }
            $request = Get-LFMRecordedRequest

            $request.Parameters['artist'] | Should -BeExactly $artist
            # api_keyApiKeyValueartistSigur Rósmethodtrack.loveskSessionKeyValuetrackHoppípollaSharedSecretValue
            $request.Parameters['api_sig'] | Should -Be '77A235A88381FFE7DD32E9E631AA657E'
        }
    }

    Context 'An authorization exchange with explicit Credentials' {

        BeforeEach {
            InModuleScope @module {
                $credentials = @{ ApiKey = 'AppKey'; SharedSecret = 'AppSecret' }
                $null = Invoke-LFMApiMethod -Method 'auth.getToken' -Credentials $credentials
                $null = Invoke-LFMApiMethod -Method 'auth.getSession' -Parameter @{ Token = 'TokenValue' } -Credentials $credentials
            }
            $token, $session = Get-LFMRecordedRequest
        }

        It 'Is sent as a GET' {
            $token.HttpMethod | Should -Be 'Get'
            $session.HttpMethod | Should -Be 'Get'
        }

        It 'Uses the API Key it was given rather than the Configuration' {
            $token.Parameters['api_key'] | Should -Be 'AppKey'
        }

        It 'Carries no Session Key' {
            $token.Parameters.ContainsKey('sk') | Should -BeFalse
            $session.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Is signed with the Shared Secret it was given' {
            # api_keyAppKeymethodauth.getTokenAppSecret
            $token.Parameters['api_sig'] | Should -Be 'ED9263230C52E78CF69E1480E7ED19B2'
            # api_keyAppKeymethodauth.getSessiontokenTokenValueAppSecret
            $session.Parameters['api_sig'] | Should -Be '921607E0DF76C4310C106C7F34A2FC07'
        }
    }

    Context 'Parameter names' {

        It 'Takes a name from the Method''s renames when it has one' {
            InModuleScope @module {
                $null = Invoke-LFMApiMethod -Method 'track.addTags' -Parameter @{ Artist = 'Opeth'; Track = 'Windowpane'; Tag = 'prog' }
                $null = Invoke-LFMApiMethod -Method 'album.getInfo' -Parameter @{ Artist = 'Opeth'; Album = 'Damnation'; UserName = 'someone' }
            }
            $addTags, $getInfo = Get-LFMRecordedRequest

            $addTags.Parameters['tags'] | Should -Be 'prog'
            $addTags.Parameters.ContainsKey('tag') | Should -BeFalse
            $getInfo.Parameters['username'] | Should -Be 'someone'
            $getInfo.Parameters.ContainsKey('user') | Should -BeFalse
        }

        It 'Takes a name from the shared table otherwise' {
            InModuleScope @module {
                $null = Invoke-LFMApiMethod -Method 'user.getInfo' -Parameter @{ UserName = 'someone' }
                $null = Invoke-LFMApiMethod -Method 'track.scrobble' -Parameter @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800; TrackNumber = 3 }
            }
            $getInfo, $scrobble = Get-LFMRecordedRequest

            $getInfo.Parameters['user'] | Should -Be 'someone'
            $scrobble.Parameters['trackNumber'] | Should -Be '3'
        }

        It 'Removes the common parameters and PassThru without complaint' {
            InModuleScope @module {
                $null = Invoke-LFMApiMethod -Method 'track.love' -Parameter @{
                    Artist = 'Opeth'; Track = 'Windowpane'; Verbose = $true; WhatIf = $false; Confirm = $false; PassThru = $true
                }
            }
            $request = Get-LFMRecordedRequest

            $request.Parameters.Keys | Sort-Object | Should -Be @('api_key', 'api_sig', 'artist', 'format', 'method', 'sk', 'track')
        }

        It 'Throws on a name it does not know rather than dropping it' {
            {
                InModuleScope @module {
                    Invoke-LFMApiMethod -Method 'track.love' -Parameter @{ Artist = 'Opeth'; Track = 'Windowpane'; Mood = 'wistful' }
                }
            } | Should -Throw '*Mood*'

            Get-LFMRecordedRequest | Should -BeNullOrEmpty
        }
    }

    Context 'Parameter values' {

        BeforeEach {
            InModuleScope @module {
                $null = Invoke-LFMApiMethod -Method 'user.getRecentTracks' -Parameter @{
                    StartDate = [datetime]::new(2026, 9, 28, 12, 0, 0, [DateTimeKind]::Utc)
                }
                $null = Invoke-LFMApiMethod -Method 'track.getInfo' -Parameter @{
                    Artist = 'Opeth'; Track = 'Windowpane'; AutoCorrect = [switch] $true
                }
                $null = Invoke-LFMApiMethod -Method 'track.getInfo' -Parameter @{
                    Artist = 'Opeth'; Track = 'Windowpane'; AutoCorrect = [switch] $false
                }
                $null = Invoke-LFMApiMethod -Method 'track.getInfo' -Parameter @{
                    Id = [guid] '12345678-1234-1234-1234-123456789012'
                }
                $null = Invoke-LFMApiMethod -Method 'track.addTags' -Parameter @{
                    Artist = 'Opeth'; Track = 'Windowpane'; Tag = [string[]] @('rock', 'indie')
                }
                $null = Invoke-LFMApiMethod -Method 'user.getTopArtists' -Parameter @{
                    UserName = 'someone'; TimePeriod = '7 Days'
                }
            }
            $date, $switchOn, $switchOff, $guid, $array, $period = Get-LFMRecordedRequest
        }

        It 'Sends a datetime as Unix time' {
            $date.Parameters['from'] | Should -Be '1790596800'
        }

        It 'Sends a switch as 1 or 0' {
            $switchOn.Parameters['autocorrect'] | Should -Be '1'
            $switchOff.Parameters['autocorrect'] | Should -Be '0'
        }

        It 'Sends a guid as its string form' {
            $guid.Parameters['mbid'] | Should -Be '12345678-1234-1234-1234-123456789012'
        }

        It 'Sends a string array comma-joined' {
            $array.Parameters['tags'] | Should -BeExactly 'rock,indie'
        }

        It 'Sends a time period as Last.fm names it' {
            $period.Parameters['period'] | Should -BeExactly '7day'
        }
    }

    Context 'A batch' {

        BeforeEach {
            InModuleScope @module {
                $null = Invoke-LFMApiMethod -Method 'track.scrobble' -Batch @(
                    @{ Artist = 'Opeth'; Track = 'Windowpane'; Timestamp = 1790596800; TrackNumber = 1 }
                    @{ Artist = 'Katatonia'; Track = 'Ghost Of The Sun'; Timestamp = 1790597100 }
                )
            }
            $request = Get-LFMRecordedRequest
        }

        It 'Is sent as one POST' {
            @($request).Count | Should -Be 1
            $request.HttpMethod | Should -Be 'Post'
        }

        It 'Numbers each parameter set under Last.fm names' {
            $request.Parameters['artist[0]'] | Should -Be 'Opeth'
            $request.Parameters['track[0]'] | Should -Be 'Windowpane'
            $request.Parameters['timestamp[0]'] | Should -Be '1790596800'
            $request.Parameters['trackNumber[0]'] | Should -Be '1'
            $request.Parameters['artist[1]'] | Should -Be 'Katatonia'
            $request.Parameters['track[1]'] | Should -Be 'Ghost Of The Sun'
            $request.Parameters['timestamp[1]'] | Should -Be '1790597100'
            $request.Parameters.ContainsKey('trackNumber[1]') | Should -BeFalse
        }

        It 'Is signed with the names sorted ordinally' {
            # trackNumber[0] sorts before track[0], because 'N' is below '[' bytewise.
            # api_keyApiKeyValueartist[0]Opethartist[1]Katatoniamethodtrack.scrobbleskSessionKeyValue
            # timestamp[0]1790596800timestamp[1]1790597100trackNumber[0]1track[0]Windowpane
            # track[1]Ghost Of The SunSharedSecretValue
            $request.Parameters['api_sig'] | Should -Be 'EE0B76B1AB55A0C1EE8B5EF2881D6EC2'
        }
    }
}

# Not faked: Invoke-RestMethod itself writes the whole URI when verbose, which a fake would
# hide. The request goes to a port nothing listens on, so it fails before leaving the machine.
Describe 'Invoke-LFMApiMethod: Unit, unfaked' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }

        $original = InModuleScope @module { @{ Config = $script:LFMConfig; BaseUrl = $script:baseUrl } }

        InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{
                ApiKey       = 'ApiKeyValue'
                SessionKey   = 'SessionKeyValue'
                SharedSecret = 'SharedSecretValue'
            }
            $script:baseUrl = 'http://127.0.0.1:9'
        }
    }

    AfterAll {
        InModuleScope @module -Parameters $original {
            param ($Config, $BaseUrl)
            $script:LFMConfig = $Config
            $script:baseUrl = $BaseUrl
        }
    }

    It 'Keeps the Session Key out of the request''s own verbose output' {
        $streams = InModuleScope @module {
            try {
                Invoke-LFMApiMethod -Method 'track.love' -Parameter @{ Artist = 'Opeth'; Track = 'Windowpane' } -Verbose *>&1
            }
            catch {
                $_
            }
        }

        $streams | Should -Not -BeNullOrEmpty
        ($streams | Out-String) | Should -Not -Match 'SessionKeyValue'
        ($streams | Out-String) | Should -Not -Match 'SharedSecretValue'
    }
}
