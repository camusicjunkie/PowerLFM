
Describe 'Get-LFMArtistTag: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistTag'.ArtistTag

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
            { Get-LFMArtistTag -Artist $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends artist.getTags as an unsigned GET' {
            $null = Get-LFMArtistTag -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'artist.getTags'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the artist' {
            $null = Get-LFMArtistTag -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Parameters['artist'] | Should -Be 'Opeth'
        }

        It 'Sends the id as mbid' {
            $id = New-Guid
            $null = Get-LFMArtistTag -Id $id

            (Get-LFMRecordedRequest).Parameters['mbid'] | Should -Be $id.ToString()
        }

        It 'Sends the user name as user' {
            $null = Get-LFMArtistTag -Artist 'Opeth' -UserName 'camusicjunkie'

            (Get-LFMRecordedRequest).Parameters['user'] | Should -Be 'camusicjunkie'
        }

        It 'Sends autocorrect as 1' {
            $null = Get-LFMArtistTag -Artist 'Opeth' -AutoCorrect

            (Get-LFMRecordedRequest).Parameters['autocorrect'] | Should -Be '1'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Artist = 'Artist1' }
                [pscustomobject] @{ Artist = 'Artist2' }
            ) | Get-LFMArtistTag

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['artist'] | Should -Be 'Artist2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMArtistTag -Artist Artist
        }

        It 'Should return the correct first tag name' {
            $output[0].Tag | Should -Be $contextMock.Tags.Tag[0].Name
        }

        It 'Should return the correct second tag url' {
            $output[1].Url | Should -Be $contextMock.Tags.Tag[1].Url
        }

        It 'Artist should have two tags' {
            $output.Tag | Should -HaveCount 2
        }

        It 'Artist should have two tags when id parameter is used' {
            $output = Get-LFMArtistTag -Id (New-Guid)
            $output.Tag | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMArtistTag -Artist Artist } | Should -Throw '*Not found*'
        }
    }
}
