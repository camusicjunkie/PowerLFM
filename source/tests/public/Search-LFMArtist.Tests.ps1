
Describe 'Search-LFMArtist: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Search-LFMArtist'.Artist

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
            { Search-LFMArtist -Artist $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Search-LFMArtist -Artist Artist -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Search-LFMArtist -Artist Artist -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Request' {

        It 'Sends artist.search as an unsigned GET' {
            $null = Search-LFMArtist -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'artist.search'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the artist' {
            $null = Search-LFMArtist -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Parameters['artist'] | Should -Be 'Opeth'
        }

        It 'Sends the limit and page' {
            $null = Search-LFMArtist -Artist 'Opeth' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Artist = 'Artist1' }
                [pscustomobject] @{ Artist = 'Artist2' }
            ) | Search-LFMArtist

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['artist'] | Should -Be 'Artist2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Search-LFMArtist -Artist Artist
        }

        It 'Should return the correct first searched artist name' {
            $output[0].Artist | Should -Be $contextMock.Results.ArtistMatches.Artist[0].Name
        }

        It 'Should return the correct first searched artist listener count' {
            $output[0].Listeners | Should -Be $contextMock.Results.ArtistMatches.Artist[0].Listeners
        }

        It 'Should return the correct first searched artist url' {
            $output[0].Url | Should -Be $contextMock.Results.ArtistMatches.Artist[0].Url
        }

        It 'Should return the correct second searched artist url' {
            $output[1].Url | Should -Be $contextMock.Results.ArtistMatches.Artist[1].Url
        }

        It 'Should return the correct second searched artist id' {
            $output[1].Id | Should -Be $contextMock.Results.ArtistMatches.Artist[1].Mbid
        }

        It 'Searched result should have two artists' {
            $output | Should -Not -BeNullOrEmpty
            $output | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Search-LFMArtist -Artist Artist } | Should -Throw '*Not found*'
        }
    }
}
