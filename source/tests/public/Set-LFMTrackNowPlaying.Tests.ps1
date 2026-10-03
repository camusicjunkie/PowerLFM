Describe 'Set-LFMTrackNowPlaying: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Set-LFMTrackNowPlaying'.TrackNowPlaying

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
        Register-LFMFakeRestMethod -Response $contextMock
    }

    Context 'Input' {

        It 'Should throw when artist is null' {
            { Set-LFMTrackNowPlaying -Artist $null } | Should -Throw
        }

        It 'Should throw when track is null' {
            { Set-LFMTrackNowPlaying -Track $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends track.updateNowPlaying as a signed POST' {
            Set-LFMTrackNowPlaying -Artist 'Opeth' -Track 'Windowpane'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'track.updateNowPlaying'
            $request.HttpMethod | Should -Be 'Post'
            $request.Parameters['sk'] | Should -Be 'SessionKeyValue'
            $request.Parameters['api_sig'] | Should -Match '^[0-9A-F]{32}$'
        }

        It 'Sends the track under Last.fm names' {
            $npParams = @{
                Artist   = 'Opeth'
                Track    = 'Windowpane'
                Album    = 'Damnation'
                Id       = '12345678-1234-1234-1234-123456789012'
                Duration = 469
            }
            Set-LFMTrackNowPlaying @npParams -PassThru

            $request = Get-LFMRecordedRequest
            $request.Parameters['artist'] | Should -BeExactly 'Opeth'
            $request.Parameters['track'] | Should -BeExactly 'Windowpane'
            $request.Parameters['album'] | Should -BeExactly 'Damnation'
            $request.Parameters['mbid'] | Should -Be '12345678-1234-1234-1234-123456789012'
            $request.Parameters['duration'] | Should -Be '469'
            $request.Parameters.Keys | Should -Not -Contain 'passthru'
        }
    }

    Context 'Output' {

        It 'Should send proper output when -Whatif is used' {
            $output = Set-LFMTrackNowPlaying -Artist Artist -Track Track -Verbose 4>&1 | Out-String
            $output | Should -Match 'Performing the operation "Setting track to now playing" on target "Track: Track".'
        }

        It 'Never shows the Shared Secret or the Session Key when verbose' {
            $output = Set-LFMTrackNowPlaying -Artist 'Opeth' -Track 'Windowpane' -Verbose *>&1 | Out-String

            $output | Should -Not -Match 'SharedSecretValue'
            $output | Should -Not -Match 'SessionKeyValue'
        }

        It 'Should output an object when -PassThru is used' {
            $output = Set-LFMTrackNowPlaying -Artist Artist -Track Track -PassThru
            $output.Artist | Should -Be $contextMock.NowPlaying.Artist.'#text'
            $output.Album | Should -Be $contextMock.NowPlaying.Album.'#text'
            $output.Track | Should -Be $contextMock.NowPlaying.Track.'#text'
        }

        It 'Should throw when Last.fm ignored the update' {
            $ignored = [pscustomobject] @{
                nowplaying = [pscustomobject] @{ ignoredMessage = [pscustomobject] @{ code = 2; '#text' = '' } }
            }
            Register-LFMFakeRestMethod -Response $ignored

            { Set-LFMTrackNowPlaying -Artist Artist -Track Track } |
                Should -Throw 'Request has been filtered because of bad meta data. Filtered track.'
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Track not found' })

            { Set-LFMTrackNowPlaying -Track Track -Artist Artist } | Should -Throw '*Track not found*'
        }
    }
}
