
Describe 'Get-LFMTagTopAlbum: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTagTopAlbum'.TagTopAlbum

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

        It 'Should throw when tag is null' {
            { Get-LFMTagTopAlbum -Tag $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends tag.getTopAlbums as an unsigned GET' {
            $null = Get-LFMTagTopAlbum -Tag 'Black Metal'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'tag.getTopAlbums'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the tag as tag' {
            $null = Get-LFMTagTopAlbum -Tag 'Black Metal'

            (Get-LFMRecordedRequest).Parameters['tag'] | Should -Be 'Black Metal'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMTagTopAlbum -Tag 'Black Metal' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Tag = 'Tag1' }
                [pscustomobject] @{ Tag = 'Tag2' }
            ) | Get-LFMTagTopAlbum

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['tag'] | Should -Be 'Tag2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMTagTopAlbum -Tag Tag
        }

        It 'Should return the correct first top album name' {
            $output[0].Album | Should -Be $contextMock.Albums.Album[0].Name
        }

        It 'Should return the correct first top album artist name' {
            $output[0].Artist | Should -Be $contextMock.Albums.Album[0].Artist.Name
        }

        It 'Should return the correct first top album url' {
            $output[0].AlbumUrl | Should -Be $contextMock.Albums.Album[0].Url
        }

        It 'Should return the correct first top album rank' {
            $output[0].Rank | Should -Be $contextMock.Albums.Album[0].'@attr'.Rank
        }

        It 'Should return the correct second top album rank' {
            $output[1].Rank | Should -Be $contextMock.Albums.Album[1].'@attr'.Rank
        }

        It 'Should return the correct second top album url' {
            $output[1].AlbumUrl | Should -Be $contextMock.Albums.Album[1].Url
        }

        It 'Should return the correct second top album artist id' {
            $output[1].ArtistId | Should -Be $contextMock.Albums.Album[1].Artist.Mbid
        }

        It 'Should return the correct second top album artist url' {
            $output[1].ArtistUrl | Should -Be $contextMock.Albums.Album[1].Artist.Url
        }

        It 'Tag should have two top albums' {
            $output.Album | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMTagTopAlbum -Tag Tag } | Should -Throw '*Not found*'
        }
    }
}
