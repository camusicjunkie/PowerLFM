
Describe 'Get-LFMArtistTopAlbum: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistTopAlbum'.ArtistTopAlbum

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
            { Get-LFMArtistTopAlbum -Artist $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends artist.getTopAlbums as an unsigned GET' {
            $null = Get-LFMArtistTopAlbum -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'artist.getTopAlbums'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the artist' {
            $null = Get-LFMArtistTopAlbum -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Parameters['artist'] | Should -Be 'Opeth'
        }

        It 'Sends the id as mbid' {
            $id = New-Guid
            $null = Get-LFMArtistTopAlbum -Id $id

            (Get-LFMRecordedRequest).Parameters['mbid'] | Should -Be $id.ToString()
        }

        It 'Sends autocorrect as 1' {
            $null = Get-LFMArtistTopAlbum -Artist 'Opeth' -AutoCorrect

            (Get-LFMRecordedRequest).Parameters['autocorrect'] | Should -Be '1'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMArtistTopAlbum -Artist 'Opeth' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Artist = 'Artist1' }
                [pscustomobject] @{ Artist = 'Artist2' }
            ) | Get-LFMArtistTopAlbum

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['artist'] | Should -Be 'Artist2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMArtistTopAlbum -Artist Artist
        }

        It 'Should return the correct first top album name' {
            $output[0].Album | Should -Be $contextMock.TopAlbums.Album[0].Name
        }

        It 'Should return the correct first top album id' {
            $output[0].Id | Should -Be $contextMock.TopAlbums.Album[0].Mbid
        }

        It 'Should return the correct second top album url' {
            $output[1].Url | Should -Be $contextMock.TopAlbums.Album[1].Url
        }

        It 'Should return the correct second top album play count' {
            $output[1].PlayCount | Should -BeOfType [int]
            $output[1].PlayCount | Should -Be $contextMock.TopAlbums.Album[1].PlayCount
        }

        It 'Artist should have two top albums' {
            $output.Album | Should -HaveCount 2
        }

        It 'Artist should have two top albums when id parameter is used' {
            $output = Get-LFMArtistTopAlbum -Id (New-Guid)
            $output.Album | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMArtistTopAlbum -Artist Artist } | Should -Throw '*Not found*'
        }
    }
}
