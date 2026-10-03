
Describe 'Get-LFMTrackTopTag: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTrackTopTag'.TrackTopTag

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

        It 'Should throw when track is null' {
            { Get-LFMTrackTopTag -Track $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends track.getTopTags as an unsigned GET' {
            $null = Get-LFMTrackTopTag -Track 'Windowpane' -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'track.getTopTags'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the track and artist' {
            $null = Get-LFMTrackTopTag -Track 'Windowpane' -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Parameters['track'] | Should -Be 'Windowpane'
            $request.Parameters['artist'] | Should -Be 'Opeth'
        }

        It 'Sends the id as mbid' {
            $id = New-Guid
            $null = Get-LFMTrackTopTag -Id $id

            (Get-LFMRecordedRequest).Parameters['mbid'] | Should -Be $id.ToString()
        }

        It 'Sends autocorrect as 1' {
            $null = Get-LFMTrackTopTag -Track 'Windowpane' -Artist 'Opeth' -AutoCorrect

            (Get-LFMRecordedRequest).Parameters['autocorrect'] | Should -Be '1'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Track = 'Track1'; Artist = 'Artist1' }
                [pscustomobject] @{ Track = 'Track2'; Artist = 'Artist2' }
            ) | Get-LFMTrackTopTag

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['track'] | Should -Be 'Track2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMTrackTopTag -Artist Artist -Track Track
        }

        It 'Should return the correct first top tag name' {
            $output[0].Tag | Should -Be $contextMock.TopTags.Tag[0].Name
        }

        It 'Should return the correct second tag url' {
            $output[1].Url | Should -Be $contextMock.TopTags.Tag[1].Url
        }

        It 'Should return the correct first tag match count' {
            $output[0].Match | Should -Be $contextMock.TopTags.Tag[0].Count
        }

        It 'Should return the correct second tag match count' {
            $output[1].Match | Should -Be $contextMock.TopTags.Tag[1].Count
        }

        It 'Track should have two tags' {
            $output.Tag | Should -HaveCount 2
        }

        It 'Track should have two tags when id parameter is used' {
            $output = Get-LFMTrackTopTag -Id (New-Guid)
            $output.Tag | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMTrackTopTag -Track Track -Artist Artist } | Should -Throw '*Not found*'
        }
    }
}
