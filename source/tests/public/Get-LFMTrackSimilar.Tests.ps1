
Describe 'Get-LFMTrackSimilar: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTrackSimilar'.TrackSimilar

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
            { Get-LFMTrackSimilar -Track $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends track.getSimilar as an unsigned GET' {
            $null = Get-LFMTrackSimilar -Track 'Windowpane' -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'track.getSimilar'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the track and artist' {
            $null = Get-LFMTrackSimilar -Track 'Windowpane' -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Parameters['track'] | Should -Be 'Windowpane'
            $request.Parameters['artist'] | Should -Be 'Opeth'
        }

        It 'Sends the id as mbid' {
            $id = New-Guid
            $null = Get-LFMTrackSimilar -Id $id

            (Get-LFMRecordedRequest).Parameters['mbid'] | Should -Be $id.ToString()
        }

        It 'Sends autocorrect as 1' {
            $null = Get-LFMTrackSimilar -Track 'Windowpane' -Artist 'Opeth' -AutoCorrect

            (Get-LFMRecordedRequest).Parameters['autocorrect'] | Should -Be '1'
        }

        It 'Sends the limit' {
            $null = Get-LFMTrackSimilar -Track 'Windowpane' -Artist 'Opeth' -Limit 7

            (Get-LFMRecordedRequest).Parameters['limit'] | Should -Be '7'
        }

        It 'Sends a limit of 5 when none is given' {
            $null = Get-LFMTrackSimilar -Track 'Windowpane' -Artist 'Opeth'

            (Get-LFMRecordedRequest).Parameters['limit'] | Should -Be '5'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Track = 'Track1'; Artist = 'Artist1' }
                [pscustomobject] @{ Track = 'Track2'; Artist = 'Artist2' }
            ) | Get-LFMTrackSimilar

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['track'] | Should -Be 'Track2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMTrackSimilar -Track Track -Artist Artist
        }

        It 'Should return the correct first similar track name' {
            $output[0].Track | Should -Be $contextMock.SimilarTracks.Track[0].Name
        }

        It 'Should return the correct first similar track match value' {
            $output[0].Match | Should -Be $contextMock.SimilarTracks.Track[0].Match
        }

        It 'Should return the correct first similar track artist name' {
            $output[0].Artist | Should -Be $contextMock.SimilarTracks.Track[0].Artist.Name
        }

        It 'Should return the correct second similar track match value' {
            $output[1].Match | Should -Be $contextMock.SimilarTracks.Track[1].Match
        }

        It 'Should return the correct second similar track url' {
            $output[1].Url | Should -Be $contextMock.SimilarTracks.Track[1].Url
        }

        It 'Track should have two similar tracks' {
            $output.Track | Should -HaveCount 2
        }

        It 'Track should return two similar tracks when id parameter is used' {
            $output = Get-LFMTrackSimilar -Id (New-Guid)
            $output.Track | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMTrackSimilar -Track Track -Artist Artist } | Should -Throw '*Not found*'
        }
    }
}
