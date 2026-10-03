
Describe 'Search-LFMAlbum: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Search-LFMAlbum'.Album

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

        It 'Should throw when album is null' {
            { Search-LFMAlbum -Album $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Search-LFMAlbum -Album Album -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Search-LFMAlbum -Album Album -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Request' {

        It 'Sends album.search as an unsigned GET' {
            $null = Search-LFMAlbum -Album 'Blackwater Park'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'album.search'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the album' {
            $null = Search-LFMAlbum -Album 'Blackwater Park'

            $request = Get-LFMRecordedRequest
            $request.Parameters['album'] | Should -Be 'Blackwater Park'
        }

        It 'Sends the limit and page' {
            $null = Search-LFMAlbum -Album 'Blackwater Park' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Album = 'Album1' }
                [pscustomobject] @{ Album = 'Album2' }
            ) | Search-LFMAlbum

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['album'] | Should -Be 'Album2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Search-LFMAlbum -Album Album
        }

        It 'Should return the correct first searched album name' {
            $output[0].Album | Should -Be $contextMock.Results.AlbumMatches.Album[0].Name
        }

        It 'Should return the correct first searched album artist name' {
            $output[0].Artist | Should -Be $contextMock.Results.AlbumMatches.Album[0].Artist
        }

        It 'Should return the correct first searched album url' {
            $output[0].Url | Should -Be $contextMock.Results.AlbumMatches.Album[0].Url
        }

        It 'Should return the correct second searched album url' {
            $output[1].Url | Should -Be $contextMock.Results.AlbumMatches.Album[1].Url
        }

        It 'Should return the correct second searched album id' {
            $output[1].Id | Should -Be $contextMock.Results.AlbumMatches.Album[1].Mbid
        }

        It 'Searched result should have two albums' {
            $output.Album | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Search-LFMAlbum -Album Album } | Should -Throw '*Not found*'
        }
    }
}
