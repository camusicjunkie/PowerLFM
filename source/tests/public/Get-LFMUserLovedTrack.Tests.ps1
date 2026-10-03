
Describe 'Get-LFMUserLovedTrack: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserLovedTrack'.UserLovedTrack

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
            { Get-LFMUserLovedTrack -UserName $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends user.getLovedTracks as an unsigned GET' {
            $null = Get-LFMUserLovedTrack -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'user.getLovedTracks'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the username as user' {
            $null = Get-LFMUserLovedTrack -UserName 'camusicjunkie'

            (Get-LFMRecordedRequest).Parameters['user'] | Should -Be 'camusicjunkie'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMUserLovedTrack -UserName 'camusicjunkie' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ UserName = 'User1' }
                [pscustomobject] @{ UserName = 'User2' }
            ) | Get-LFMUserLovedTrack

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['user'] | Should -Be 'User2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMUserLovedTrack
        }

        It 'Should return the correct first loved track name' {
            $output[0].Track | Should -Be $contextMock.LovedTracks.Track[0].Name
        }

        It 'Should return the correct first loved track artist name' {
            $output[0].Artist | Should -Be $contextMock.LovedTracks.Track[0].Artist.Name
        }

        It 'Should return the correct first loved track id' {
            $output[0].TrackId | Should -Be $contextMock.LovedTracks.Track[0].Mbid
        }

        It 'Should return the correct second loved track artist id' {
            $output[1].ArtistId | Should -Be $contextMock.LovedTracks.Track[1].Artist.Mbid
        }

        It 'Should return the correct second loved track artist url' {
            $output[1].ArtistUrl | Should -Be $contextMock.LovedTracks.Track[1].Artist.Url
        }

        It 'Should return the correct second loved track url' {
            $output[1].TrackUrl | Should -Be $contextMock.LovedTracks.Track[1].Url
        }

        It 'User should have two loved tracks' {
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

            { Get-LFMUserLovedTrack } | Should -Throw '*Not found*'
        }
    }
}
