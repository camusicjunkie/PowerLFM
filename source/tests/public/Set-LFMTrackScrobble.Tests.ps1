Describe 'Set-LFMTrackScrobble: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Set-LFMTrackScrobble'.TrackScrobble

        $module = @{ ModuleName = 'PowerLFM' }

        $originalConfig = InModuleScope @module { $script:LFMConfig }

        InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{
                ApiKey       = 'ApiKeyValue'
                SessionKey   = 'SessionKeyValue'
                SharedSecret = 'SharedSecretValue'
            }
        }

        # 1790596800 in Unix time.
        $script:dateTime = [datetime]::new(2026, 9, 28, 12, 0, 0, [DateTimeKind]::Utc)

        Mock Send-LFMScrobbleQueue -ModuleName 'PowerLFM'
        Mock Add-LFMPendingScrobble -ModuleName 'PowerLFM'
    }

    AfterAll {
        InModuleScope @module -Parameters @{ Config = $originalConfig } {
            param ($Config)
            $script:LFMConfig = $Config
        }
    }

    BeforeEach {
        Register-LFMFakeRestMethod -Response $contextMock
    }

    Context 'Input' {
        It 'Should throw when artist is null' {
            { Set-LFMTrackScrobble -Artist $null } | Should -Throw
        }

        It 'Should throw when track is null' {
            { Set-LFMTrackScrobble -Track $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends track.scrobble as a signed POST' {
            Set-LFMTrackScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $dateTime

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'track.scrobble'
            $request.HttpMethod | Should -Be 'Post'
            $request.Parameters['sk'] | Should -Be 'SessionKeyValue'
            $request.Parameters['api_sig'] | Should -Match '^[0-9A-F]{32}$'
        }

        It 'Sends the play under Last.fm names' {
            $sfParams = @{
                Artist      = 'Opeth'
                Track       = 'Windowpane'
                Timestamp   = $dateTime
                Album       = 'Damnation'
                Id          = '12345678-1234-1234-1234-123456789012'
                TrackNumber = 3
                Duration    = 469
            }
            Set-LFMTrackScrobble @sfParams

            $request = Get-LFMRecordedRequest
            $request.Parameters['artist'] | Should -BeExactly 'Opeth'
            $request.Parameters['track'] | Should -BeExactly 'Windowpane'
            $request.Parameters['timestamp'] | Should -Be '1790596800'
            $request.Parameters['album'] | Should -BeExactly 'Damnation'
            $request.Parameters['mbid'] | Should -Be '12345678-1234-1234-1234-123456789012'
            $request.Parameters['trackNumber'] | Should -Be '3'
            $request.Parameters['duration'] | Should -Be '469'
        }

        It 'Leaves PassThru off the request' {
            Set-LFMTrackScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $dateTime -PassThru

            (Get-LFMRecordedRequest).Parameters.Keys | Should -Not -Contain 'passthru'
        }
    }

    Context 'Output' {

        It 'Should send proper output when -Whatif is used' {
            $output = Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime -Verbose 4>&1 | Out-String
            $output | Should -Match 'Performing the operation "Setting track to now playing" on target "Track: Track".'
        }

        It 'Never shows the Shared Secret or the Session Key when verbose' {
            $output = Set-LFMTrackScrobble -Artist 'Opeth' -Track 'Windowpane' -Timestamp $dateTime -Verbose *>&1 | Out-String

            $output | Should -Not -Match 'SharedSecretValue'
            $output | Should -Not -Match 'SessionKeyValue'
        }

        It 'Should output an object when -PassThru is used' {
            $output = Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime -PassThru
            $output.Artist | Should -Be $contextMock.Scrobbles.Scrobble.Artist.'#text'
            $output.Album | Should -Be $contextMock.Scrobbles.Scrobble.Album.'#text'
            $output.Track | Should -Be $contextMock.Scrobbles.Scrobble.Track.'#text'
        }

        It 'Should throw when Last.fm ignored the scrobble' {
            $ignored = [pscustomobject] @{
                scrobbles = [pscustomobject] @{
                    scrobble = [pscustomobject] @{ ignoredMessage = [pscustomobject] @{ code = 1; '#text' = '' } }
                }
            }
            Register-LFMFakeRestMethod -Response $ignored

            { Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime } |
                Should -Throw 'Request has been filtered because of bad meta data. Filtered artist.'
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Track not found' })

            { Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime } | Should -Throw '*Track not found*'
        }
    }

    Context 'Scrobble queue' {

        BeforeAll {
            # Thrown with no response behind it, as when Last.fm cannot be reached.
            $script:unreachable = { throw [System.Net.WebException]::new('No route to host') }
        }

        It 'Should attempt to flush the queue before submitting' {
            Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime

            $siParams = @{
                CommandName = 'Send-LFMScrobbleQueue'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Attempts one flush for a run of scrobbles rather than one for each' {
            # The flush sits in begin, so a pipeline of plays flushes at the start and not
            # between every track. Asserting the three scrobbles as well, because one
            # flush is only the right answer if all three of them happened.
            $plays = @(
                [pscustomobject] @{ Artist = 'Artist'; Track = 'One'; Timestamp = $dateTime }
                [pscustomobject] @{ Artist = 'Artist'; Track = 'Two'; Timestamp = $dateTime }
                [pscustomobject] @{ Artist = 'Artist'; Track = 'Three'; Timestamp = $dateTime }
            )

            $plays | Set-LFMTrackScrobble

            $siParams = @{
                CommandName = 'Send-LFMScrobbleQueue'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
            Should -Invoke @siParams

            @(Get-LFMRecordedRequest).Count | Should -Be 3
        }

        It 'Should queue the scrobble when Last.fm could not be reached' {
            Mock Invoke-RestMethod $unreachable -ModuleName 'PowerLFM'
            Mock Add-LFMPendingScrobble {
                [pscustomobject] @{ PSTypeName = 'PowerLFM.Track.PendingScrobble'; Track = 'Track' }
            } -ModuleName 'PowerLFM'

            Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime

            $siParams = @{
                CommandName     = 'Add-LFMPendingScrobble'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    $Artist -eq 'Artist' -and
                    $Track -eq 'Track' -and
                    $Timestamp -eq $dateTime
                }
            }
            Should -Invoke @siParams
        }

        It 'Should output a pending scrobble when queued with -PassThru' {
            Mock Invoke-RestMethod $unreachable -ModuleName 'PowerLFM'
            Mock Add-LFMPendingScrobble {
                [pscustomobject] @{ PSTypeName = 'PowerLFM.Track.PendingScrobble'; Track = 'Track' }
            } -ModuleName 'PowerLFM'

            $output = Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime -PassThru

            $output.PSTypeNames | Should -Contain 'PowerLFM.Track.PendingScrobble'
        }

        It 'Should not queue the scrobble when Last.fm returned an error' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Track not found' })

            { Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime } | Should -Throw

            $siParams = @{
                CommandName = 'Add-LFMPendingScrobble'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 0
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Should throw the original failure when the scrobble could not be queued' {
            Mock Invoke-RestMethod $unreachable -ModuleName 'PowerLFM'
            Mock Add-LFMPendingScrobble { } -ModuleName 'PowerLFM'

            { Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime } |
                Should -Throw 'Last.fm could not be reached.*'
        }
    }
}
