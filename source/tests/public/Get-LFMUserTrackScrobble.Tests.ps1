
Describe 'Get-LFMUserTrackScrobble: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserTrackScrobble'.UserTrackScrobble

        $module = @{ ModuleName = 'PowerLFM' }

        $originalConfig = InModuleScope @module { $script:LFMConfig }

        InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{
                ApiKey       = 'ApiKeyValue'
                SessionKey   = 'SessionKeyValue'
                SharedSecret = 'SharedSecretValue'
            }
        }

        Mock ConvertFrom-UnixTime -ModuleName 'PowerLFM'
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
            { Get-LFMUserTrackScrobble -Track $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Get-LFMUserTrackScrobble -Track Track -Artist Artist -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Get-LFMUserTrackScrobble -Track Track -Artist Artist -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Request' {

        It 'Sends user.getTrackScrobbles as an unsigned GET' {
            $null = Get-LFMUserTrackScrobble -Track 'Windowpane' -Artist 'Opeth' -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'user.getTrackScrobbles'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the track, artist and username' {
            $null = Get-LFMUserTrackScrobble -Track 'Windowpane' -Artist 'Opeth' -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Parameters['track'] | Should -Be 'Windowpane'
            $request.Parameters['artist'] | Should -Be 'Opeth'
            $request.Parameters['user'] | Should -Be 'camusicjunkie'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMUserTrackScrobble -Track 'Windowpane' -Artist 'Opeth' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Track = 'Windowpane'; Artist = 'Opeth' }
                [pscustomobject] @{ Track = 'Ghost of Perdition'; Artist = 'Opeth' }
            ) | Get-LFMUserTrackScrobble

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['track'] | Should -Be 'Ghost of Perdition'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMUserTrackScrobble -Track Track -Artist Artist
        }

        It 'Should return the correct first scrobbled track name' {
            $output[0].Track | Should -Be $contextMock.TrackScrobbles.Track[0].Name
        }

        It 'Should return the correct first scrobbled track artist name' {
            $output[0].Artist | Should -Be $contextMock.TrackScrobbles.Track[0].Artist.'#text'
        }

        It 'Should return the correct first scrobbled track id' {
            $output[0].TrackId | Should -Be $contextMock.TrackScrobbles.Track[0].Mbid
        }

        It 'Should return the correct second scrobbled track url' {
            $output[1].TrackUrl | Should -Be $contextMock.TrackScrobbles.Track[1].Url
        }

        It 'Should return the correct second scrobbled track album name' {
            $output[1].Album | Should -Be $contextMock.TrackScrobbles.Track[1].Album.'#text'
        }

        It 'User should have two scrobbled tracks' {
            $output.Track | Should -HaveCount 2
        }

        It 'Should convert the date from unix time to the local time' {
            $siParams = @{
                CommandName     = 'ConvertFrom-UnixTime'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 2
                ParameterFilter = {
                    $UnixTime -eq 0 -or
                    $UnixTime -eq 60 -and
                    $Local -eq $true
                }
            }
            Should -Invoke @siParams
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMUserTrackScrobble -Track Track -Artist Artist } | Should -Throw '*Not found*'
        }
    }
}
