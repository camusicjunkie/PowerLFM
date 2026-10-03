
Describe 'Get-LFMUserRecentTrack: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserRecentTrack'.UserRecentTrack

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
            { Get-LFMUserRecentTrack -UserName $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 201' {
            $gurtParams = @{
                UserName = 'UserName'
                Limit    = 201
            }
            { Get-LFMUserRecentTrack @gurtParams } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 200' {
            $gurtParams = @{
                UserName = 'UserName'
                Limit    = 200
            }
            { Get-LFMUserRecentTrack @gurtParams } | Should -Not -Throw
        }
    }

    Context 'Request' {

        It 'Sends user.getRecentTracks as an unsigned GET' {
            $null = Get-LFMUserRecentTrack -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'user.getRecentTracks'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the username as user' {
            $null = Get-LFMUserRecentTrack -UserName 'camusicjunkie'

            (Get-LFMRecordedRequest).Parameters['user'] | Should -Be 'camusicjunkie'
        }

        It 'Always asks for the extended response' {
            $null = Get-LFMUserRecentTrack -UserName 'camusicjunkie'

            (Get-LFMRecordedRequest).Parameters['extended'] | Should -Be '1'
        }

        It 'Sends the start and end dates as Unix time' {
            $start = [datetime]::new(2026, 9, 28, 12, 0, 0, [DateTimeKind]::Utc)
            $null = Get-LFMUserRecentTrack -UserName 'camusicjunkie' -StartDate $start -EndDate $start.AddDays(7)

            $request = Get-LFMRecordedRequest
            $request.Parameters['from'] | Should -Be '1790596800'
            $request.Parameters['to'] | Should -Be '1791201600'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMUserRecentTrack -UserName 'camusicjunkie' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ UserName = 'User1' }
                [pscustomobject] @{ UserName = 'User2' }
            ) | Get-LFMUserRecentTrack

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['user'] | Should -Be 'User2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMUserRecentTrack
        }

        It 'User first recent track should be playing now' {
            $output[0].ScrobbleTime | Should -Be 'Now Playing'
        }

        It 'Should return the correct first recent track name' {
            $output[0].Track | Should -Be $contextMock.RecentTracks.Track[0].Name
        }

        It 'Should return the correct first recent track artist name' {
            $output[0].Artist | Should -Be $contextMock.RecentTracks.Track[0].Artist.Name
        }

        It 'Should return the correct second recent track album name' {
            $output[1].Album | Should -Be $contextMock.RecentTracks.Track[1].Album.'#Text'
        }

        It 'User second recent track should be loved' {
            $output[1].Loved | Should -Be 'Yes'
        }

        It 'Should return the correct third recent track artist name' {
            $output[2].Artist | Should -Be $contextMock.RecentTracks.Track[2].Artist.Name
        }

        It 'User should have two recent tracks' {
            $output | Should -HaveCount 2
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

            { Get-LFMUserRecentTrack } | Should -Throw '*Not found*'
        }
    }
}
