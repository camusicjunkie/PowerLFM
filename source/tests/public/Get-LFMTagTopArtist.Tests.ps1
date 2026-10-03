
Describe 'Get-LFMTagTopArtist: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTagTopArtist'.TagTopArtist

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
            { Get-LFMTagTopArtist -Tag $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends tag.getTopArtists as an unsigned GET' {
            $null = Get-LFMTagTopArtist -Tag 'Black Metal'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'tag.getTopArtists'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the tag as tag' {
            $null = Get-LFMTagTopArtist -Tag 'Black Metal'

            (Get-LFMRecordedRequest).Parameters['tag'] | Should -Be 'Black Metal'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMTagTopArtist -Tag 'Black Metal' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Tag = 'Tag1' }
                [pscustomobject] @{ Tag = 'Tag2' }
            ) | Get-LFMTagTopArtist

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['tag'] | Should -Be 'Tag2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMTagTopArtist -Tag Tag
        }

        It 'Should return the correct first top artist name' {
            $output[0].Artist | Should -Be $contextMock.TopArtists.Artist[0].Name
        }

        It 'Should return the correct first top artist url' {
            $output[0].ArtistUrl | Should -Be $contextMock.TopArtists.Artist[0].Url
        }

        It 'Should return the correct first top artist rank' {
            $output[0].Rank | Should -Be $contextMock.TopArtists.Artist[0].'@attr'.Rank
        }

        It 'Should return the correct second top artist rank' {
            $output[1].Rank | Should -Be $contextMock.TopArtists.Artist[1].'@attr'.Rank
        }

        It 'Should return the correct second top artist id' {
            $output[1].ArtistId | Should -Be $contextMock.TopArtists.Artist[1].Mbid
        }

        It 'Should return the correct second top artist url' {
            $output[1].ArtistUrl | Should -Be $contextMock.TopArtists.Artist[1].Url
        }

        It 'Tag should have two top artists' {
            $output.Artist | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMTagTopArtist -Tag Tag } | Should -Throw '*Not found*'
        }
    }
}
