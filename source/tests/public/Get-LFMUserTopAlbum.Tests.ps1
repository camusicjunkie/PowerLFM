
Describe 'Get-LFMUserTopAlbum: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserTopAlbum'.UserTopAlbum

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

        It 'Should throw when username is null' {
            { Get-LFMUserTopAlbum -UserName $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Get-LFMUserTopAlbum -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Get-LFMUserTopAlbum -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Request' {

        It 'Sends user.getTopAlbums as an unsigned GET' {
            $null = Get-LFMUserTopAlbum -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'user.getTopAlbums'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the username as user' {
            $null = Get-LFMUserTopAlbum -UserName 'camusicjunkie'

            (Get-LFMRecordedRequest).Parameters['user'] | Should -Be 'camusicjunkie'
        }

        It 'Sends the time period as period' {
            $null = Get-LFMUserTopAlbum -UserName 'camusicjunkie' -TimePeriod '3 Months'

            (Get-LFMRecordedRequest).Parameters['period'] | Should -Be '3month'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMUserTopAlbum -UserName 'camusicjunkie' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ UserName = 'User1' }
                [pscustomobject] @{ UserName = 'User2' }
            ) | Get-LFMUserTopAlbum

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['user'] | Should -Be 'User2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMUserTopAlbum
        }

        It 'Should return the correct first top album name' {
            $output[0].Album | Should -Be $contextMock.TopAlbums.Album[0].Name
        }

        It 'Should return the correct first top album artist name' {
            $output[0].Artist | Should -Be $contextMock.TopAlbums.Album[0].Artist.Name
        }

        It 'Should return the correct first top album url' {
            $output[0].AlbumUrl | Should -Be $contextMock.TopAlbums.Album[0].Url
        }

        It 'Should return the correct first top album play count' {
            $output[0].PlayCount | Should -Be $contextMock.TopAlbums.Album[0].PlayCount
        }

        It 'Should return the correct second top album play count' {
            $output[1].PlayCount | Should -Be $contextMock.TopAlbums.Album[1].PlayCount
        }

        It 'Should return the correct second top album url' {
            $output[1].AlbumUrl | Should -Be $contextMock.TopAlbums.Album[1].Url
        }

        It 'Should return the correct second top album artist id' {
            $output[1].ArtistId | Should -Be $contextMock.TopAlbums.Album[1].Artist.Mbid
        }

        It 'Should return the correct second top album artist url' {
            $output[1].ArtistUrl | Should -Be $contextMock.TopAlbums.Album[1].Artist.Url
        }

        It 'User should have two top albums' {
            $output.Album | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMUserTopAlbum } | Should -Throw '*Not found*'
        }
    }
}
