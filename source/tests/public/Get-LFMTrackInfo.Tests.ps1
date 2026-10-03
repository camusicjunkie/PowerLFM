
Describe 'Get-LFMTrackInfo: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTrackInfo'.TrackInfo

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
            { Get-LFMTrackInfo -Track $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends track.getInfo as an unsigned GET' {
            $null = Get-LFMTrackInfo -Track 'Windowpane' -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'track.getInfo'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the track and artist' {
            $null = Get-LFMTrackInfo -Track 'Windowpane' -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Parameters['track'] | Should -Be 'Windowpane'
            $request.Parameters['artist'] | Should -Be 'Opeth'
        }

        It 'Sends the id as mbid' {
            $id = New-Guid
            $null = Get-LFMTrackInfo -Id $id

            (Get-LFMRecordedRequest).Parameters['mbid'] | Should -Be $id.ToString()
        }

        It 'Sends the user name as username' {
            $null = Get-LFMTrackInfo -Track 'Windowpane' -Artist 'Opeth' -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Parameters['username'] | Should -Be 'camusicjunkie'
            $request.Parameters.ContainsKey('user') | Should -BeFalse
        }

        It 'Sends autocorrect as 1' {
            $null = Get-LFMTrackInfo -Track 'Windowpane' -Artist 'Opeth' -AutoCorrect

            (Get-LFMRecordedRequest).Parameters['autocorrect'] | Should -Be '1'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Track = 'Track1'; Artist = 'Artist1' }
                [pscustomobject] @{ Track = 'Track2'; Artist = 'Artist2' }
            ) | Get-LFMTrackInfo

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['track'] | Should -Be 'Track2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMTrackInfo -Track Track -Artist Artist
        }

        It 'Should return the correct track name' {
            $output.Track | Should -Be $contextMock.Track.Name
        }

        It 'Should return the correct artist name' {
            $output.Artist | Should -Be $contextMock.Track.Artist.Name
        }

        It 'Should return the correct album name' {
            $output.Album | Should -Be $contextMock.Track.Album.Title
        }

        It 'Should return the correct track url' {
            $output.Url | Should -Be $contextMock.Track.Url
        }

        It 'Should return the correct listener count' {
            $output.Listeners | Should -BeOfType [int]
            $output.Listeners | Should -Be $contextMock.Track.Listeners
        }

        It 'Should return the correct play count' {
            $output.PlayCount | Should -BeOfType [int]
            $output.PlayCount | Should -Be $contextMock.Track.PlayCount
        }

        It 'Should return the correct first tag name' {
            $output.Tags[0].Tag | Should -Be $contextMock.Track.TopTags.Tag[0].Name
        }

        It 'Should return the correct second tag url' {
            $output.Tags[1].Url | Should -Be $contextMock.Track.TopTags.Tag[1].Url
        }

        It 'Track should have two tags' {
            $output.Tags | Should -HaveCount 2
        }

        It 'Should return the correct user play count' {
            $output = Get-LFMTrackInfo -Track Track -Artist Artist -UserName camusicjunkie
            $output.UserPlayCount | Should -Be $contextMock.Track.UserPlayCount
        }

        It 'Track should have two tags when id parameter is used' {
            $output = Get-LFMTrackInfo -Id (New-Guid)
            $output.Tags | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMTrackInfo -Track Track -Artist Artist } | Should -Throw '*Not found*'
        }
    }
}
