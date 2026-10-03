
Describe 'Search-LFMTrack: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Search-LFMTrack'.Track

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
            { Search-LFMTrack -Track $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Search-LFMTrack -Track Track -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Search-LFMTrack -Track Track -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Request' {

        It 'Sends track.search as an unsigned GET' {
            $null = Search-LFMTrack -Track 'Windowpane'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'track.search'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the track' {
            $null = Search-LFMTrack -Track 'Windowpane'

            $request = Get-LFMRecordedRequest
            $request.Parameters['track'] | Should -Be 'Windowpane'
        }

        It 'Sends the limit and page' {
            $null = Search-LFMTrack -Track 'Windowpane' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Track = 'Track1' }
                [pscustomobject] @{ Track = 'Track2' }
            ) | Search-LFMTrack

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['track'] | Should -Be 'Track2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Search-LFMTrack -Track Track
        }

        It 'Should return the correct first searched track name' {
            $output[0].Track | Should -Be $contextMock.Results.TrackMatches.Track[0].Name
        }

        It 'Should return the correct first searched track artist name' {
            $output[0].Artist | Should -Be $contextMock.Results.TrackMatches.Track[0].Artist
        }

        It 'Should return the correct first searched track url' {
            $output[0].Url | Should -Be $contextMock.Results.TrackMatches.Track[0].Url
        }

        It 'Should return the correct first searched track listener count' {
            $output[0].Listeners | Should -Be $contextMock.Results.TrackMatches.Track[0].Listeners
        }

        It 'Should return the correct second searched track url' {
            $output[1].Url | Should -Be $contextMock.Results.TrackMatches.Track[1].Url
        }

        It 'Should return the correct second searched track id' {
            $output[1].Id | Should -Be $contextMock.Results.TrackMatches.Track[1].Mbid
        }

        It 'Searched result should have two tracks' {
            $output | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Search-LFMTrack -Track Track } | Should -Throw '*Not found*'
        }
    }
}
