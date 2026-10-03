
Describe 'Get-LFMUserWeeklyArtistChart: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserWeeklyArtistChart'.UserWeeklyArtistChart

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
            { Get-LFMUserWeeklyArtistChart -UserName $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends user.getWeeklyArtistChart as an unsigned GET' {
            $null = Get-LFMUserWeeklyArtistChart -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'user.getWeeklyArtistChart'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the username as user' {
            $null = Get-LFMUserWeeklyArtistChart -UserName 'camusicjunkie'

            (Get-LFMRecordedRequest).Parameters['user'] | Should -Be 'camusicjunkie'
        }

        It 'Sends the start and end dates as Unix time' {
            $start = [datetime]::new(2026, 9, 28, 12, 0, 0, [DateTimeKind]::Utc)
            $null = Get-LFMUserWeeklyArtistChart -UserName 'camusicjunkie' -StartDate $start -EndDate $start.AddDays(7)

            $request = Get-LFMRecordedRequest
            $request.Parameters['from'] | Should -Be '1790596800'
            $request.Parameters['to'] | Should -Be '1791201600'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ UserName = 'User1' }
                [pscustomobject] @{ UserName = 'User2' }
            ) | Get-LFMUserWeeklyArtistChart

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['user'] | Should -Be 'User2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMUserWeeklyArtistChart
        }

        It 'Should return the correct first weekly artist chart name' {
            $output[0].Artist | Should -Be $contextMock.WeeklyArtistChart.Artist[0].Name
        }

        It 'Should return the correct first weekly artist chart url' {
            $output[0].Url | Should -Be $contextMock.WeeklyArtistChart.Artist[0].Url
        }

        It 'Should return the correct second weekly artist chart url' {
            $output[1].Url | Should -Be $contextMock.WeeklyArtistChart.Artist[1].Url
        }

        It 'Should return the correct second weekly artist chart id' {
            $output[1].Id | Should -Be $contextMock.WeeklyArtistChart.Artist[1].Mbid
        }

        It 'Should return the correct second weekly artist chart play count' {
            $output[1].PlayCount | Should -Be $contextMock.WeeklyArtistChart.Artist[1].PlayCount
        }

        It 'User weekly artist chart should have two artists' {
            $output.Artist | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMUserWeeklyArtistChart } | Should -Throw '*Not found*'
        }
    }
}
