
Describe 'Get-LFMTrackCorrection: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTrackCorrection'.TrackCorrection

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

        It 'Should throw when track is null' {
            { Get-LFMTrackCorrection -Track $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends track.getCorrection as an unsigned GET' {
            $null = Get-LFMTrackCorrection -Track 'Windowpane' -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'track.getCorrection'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the track and artist' {
            $null = Get-LFMTrackCorrection -Track 'Windowpane' -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Parameters['track'] | Should -Be 'Windowpane'
            $request.Parameters['artist'] | Should -Be 'Opeth'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Track = 'Track1'; Artist = 'Artist1' }
                [pscustomobject] @{ Track = 'Track2'; Artist = 'Artist2' }
            ) | Get-LFMTrackCorrection

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['track'] | Should -Be 'Track2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMTrackCorrection -Track Track -Artist Artist
        }

        It 'Should return the correct corrected track name' {
            $output.Track | Should -Be $contextMock.Corrections.Correction.Track.Name
        }

        It 'Should return the correct corrected track url' {
            $output.TrackUrl | Should -Be $contextMock.Corrections.Correction.Track.Url
        }

        It 'Should return the correct corrected track artist name' {
            $output.Artist | Should -Be $contextMock.Corrections.Correction.Track.Artist.Name
        }

        It 'Should return the correct corrected track artist id' {
            $output.ArtistId | Should -Be $contextMock.Corrections.Correction.Track.Artist.Mbid
        }

        It 'Should return the correct corrected track artist url' {
            $output.ArtistUrl | Should -Be $contextMock.Corrections.Correction.Track.Artist.Url
        }

        It 'Corrected track should have one track' {
            $output.Track | Should -HaveCount 1
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMTrackCorrection -Track Track -Artist Artist } | Should -Throw '*Not found*'
        }
    }
}
