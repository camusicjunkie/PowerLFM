
Describe 'Get-LFMArtistSimilar: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistSimilar'.ArtistSimilar

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
            { Get-LFMArtistSimilar -Artist $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends artist.getSimilar as an unsigned GET' {
            $null = Get-LFMArtistSimilar -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'artist.getSimilar'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the artist' {
            $null = Get-LFMArtistSimilar -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Parameters['artist'] | Should -Be 'Opeth'
        }

        It 'Sends the id as mbid' {
            $id = New-Guid
            $null = Get-LFMArtistSimilar -Id $id

            (Get-LFMRecordedRequest).Parameters['mbid'] | Should -Be $id.ToString()
        }

        It 'Sends autocorrect as 1' {
            $null = Get-LFMArtistSimilar -Artist 'Opeth' -AutoCorrect

            (Get-LFMRecordedRequest).Parameters['autocorrect'] | Should -Be '1'
        }

        It 'Sends the limit' {
            $null = Get-LFMArtistSimilar -Artist 'Opeth' -Limit 7

            (Get-LFMRecordedRequest).Parameters['limit'] | Should -Be '7'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Artist = 'Artist1' }
                [pscustomobject] @{ Artist = 'Artist2' }
            ) | Get-LFMArtistSimilar

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['artist'] | Should -Be 'Artist2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMArtistSimilar -Artist Artist
        }

        It 'Should return the correct first similar artist name' {
            $output[0].Artist | Should -Be $contextMock.Similarartists.Artist[0].Name
        }

        It 'Should return the correct second similar artist url' {
            $output[1].Url | Should -Be $contextMock.Similarartists.Artist[1].Url
        }

        It 'Artist should have two similar artists' {
            $output.Artist | Should -HaveCount 2
        }

        It 'Should return the correct first similar artist match value' {
            $output[0].Match | Should -Be $contextMock.Similarartists.Artist[0].Match
        }

        It 'Should return the correct second similar artist match value' {
            $output[1].Match | Should -Be $contextMock.Similarartists.Artist[1].Match
        }

        It 'Artist should return two similar artists when id parameter is used' {
            $output = Get-LFMArtistSimilar -Id (New-Guid)
            $output.Artist | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMArtistSimilar -Artist Artist } | Should -Throw '*Not found*'
        }
    }
}
