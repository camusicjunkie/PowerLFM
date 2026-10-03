
Describe 'Get-LFMGeoTopTrack: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMGeoTopTrack'.GeoTopTrack

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

        It 'Should throw when limit is greater than 119' {
            { Get-LFMGeoTopTrack -Country Country -Limit 120 } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends geo.getTopTracks as an unsigned GET' {
            $null = Get-LFMGeoTopTrack -Country 'Norway'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'geo.getTopTracks'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the country as country' {
            $null = Get-LFMGeoTopTrack -Country 'Norway'

            (Get-LFMRecordedRequest).Parameters['country'] | Should -Be 'Norway'
        }

        It 'Sends the city as location' {
            $null = Get-LFMGeoTopTrack -Country 'Norway' -City 'Oslo'

            (Get-LFMRecordedRequest).Parameters['location'] | Should -Be 'Oslo'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMGeoTopTrack -Country 'Norway' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                'Norway'
                'Sweden'
            ) | Get-LFMGeoTopTrack

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['country'] | Should -Be 'Sweden'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMGeoTopTrack -Country Country
        }

        It 'Should return the correct first top track name' {
            $output[0].Track | Should -Be $contextMock.Tracks.Track[0].Name
        }

        It 'Should return the correct first top track artist name' {
            $output[0].Artist | Should -Be $contextMock.Tracks.Track[0].Artist.Name
        }

        It 'Should return the correct first top track id' {
            $output[0].TrackId | Should -Be $contextMock.Tracks.Track[0].Mbid
        }

        It 'Should return the correct first top track listener count' {
            $output[0].Listeners | Should -BeOfType [int]
            $output[0].Listeners | Should -Be $contextMock.Tracks.Track[0].Listeners
        }

        It 'Should return the correct second top track listener count' {
            $output[1].Listeners | Should -BeOfType [int]
            $output[1].Listeners | Should -Be $contextMock.Tracks.Track[1].Listeners
        }

        It 'Should return the correct second top track artist id' {
            $output[1].ArtistId | Should -Be $contextMock.Tracks.Track[1].Artist.Mbid
        }

        It 'Should return the correct second top track artist url' {
            $output[1].ArtistUrl | Should -Be $contextMock.Tracks.Track[1].Artist.Url
        }

        It 'Should return the correct second top track url' {
            $output[1].TrackUrl | Should -Be $contextMock.Tracks.Track[1].Url
        }

        It 'Country should have two top tracks' {
            $output.Track | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMGeoTopTrack -Country Country } | Should -Throw '*Not found*'
        }
    }
}
