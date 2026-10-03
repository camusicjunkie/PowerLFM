
Describe 'Get-LFMGeoTopArtist: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMGeoTopArtist'.GeoTopArtist

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
            { Get-LFMGeoTopArtist -Country Country -Limit 120 } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends geo.getTopArtists as an unsigned GET' {
            $null = Get-LFMGeoTopArtist -Country 'Norway'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'geo.getTopArtists'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the country as country' {
            $null = Get-LFMGeoTopArtist -Country 'Norway'

            (Get-LFMRecordedRequest).Parameters['country'] | Should -Be 'Norway'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMGeoTopArtist -Country 'Norway' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                'Norway'
                'Sweden'
            ) | Get-LFMGeoTopArtist

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['country'] | Should -Be 'Sweden'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMGeoTopArtist -Country Country
        }

        It 'Should return the correct first top artist name' {
            $output[0].Artist | Should -Be $contextMock.TopArtists.Artist[0].Name
        }

        It 'Should return the correct first top artist id' {
            $output[0].Id | Should -Be $contextMock.TopArtists.Artist[0].Mbid
        }

        It 'Should return the correct first top artist listener count' {
            $output[0].Listeners | Should -BeOfType [int]
            $output[0].Listeners | Should -Be $contextMock.TopArtists.Artist[0].Listeners
        }

        It 'Should return the correct second top artist listener count' {
            $output[1].Listeners | Should -BeOfType [int]
            $output[1].Listeners | Should -Be $contextMock.TopArtists.Artist[1].Listeners
        }

        It 'Should return the correct second top artist url' {
            $output[1].Url | Should -Be $contextMock.TopArtists.Artist[1].Url
        }

        It 'Country should have two top artists' {
            $output.Artist | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMGeoTopArtist -Country Country } | Should -Throw '*Not found*'
        }
    }
}
