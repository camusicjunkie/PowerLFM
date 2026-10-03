
Describe 'Get-LFMUserTopArtist: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserTopArtist'.UserTopArtist

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
            { Get-LFMUserTopArtist -UserName $null } | Should -Throw
        }

        It 'Should throw when limit has more than 50 values' {
            { Get-LFMUserTopArtist -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Get-LFMUserTopArtist -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Request' {

        It 'Sends user.getTopArtists as an unsigned GET' {
            $null = Get-LFMUserTopArtist -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'user.getTopArtists'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the username as user' {
            $null = Get-LFMUserTopArtist -UserName 'camusicjunkie'

            (Get-LFMRecordedRequest).Parameters['user'] | Should -Be 'camusicjunkie'
        }

        It 'Sends the time period as period' {
            $null = Get-LFMUserTopArtist -UserName 'camusicjunkie' -TimePeriod '3 Months'

            (Get-LFMRecordedRequest).Parameters['period'] | Should -Be '3month'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMUserTopArtist -UserName 'camusicjunkie' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ UserName = 'User1' }
                [pscustomobject] @{ UserName = 'User2' }
            ) | Get-LFMUserTopArtist

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['user'] | Should -Be 'User2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMUserTopArtist
        }

        It 'Should return the correct first top artist name' {
            $output[0].Artist | Should -Be $contextMock.TopArtists.Artist[0].Name
        }

        It 'Should return the correct first top artist id' {
            $output[0].Id | Should -Be $contextMock.TopArtists.Artist[0].Mbid
        }

        It 'Should return the correct second top artist url' {
            $output[1].Url | Should -Be $contextMock.TopArtists.Artist[1].Url
        }

        It 'Should return the correct second top artist play count' {
            $output[1].PlayCount | Should -BeOfType [int]
            $output[1].PlayCount | Should -Be $contextMock.TopArtists.Artist[1].PlayCount
        }

        It 'User should have two top artists' {
            $output.Artist | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMUserTopArtist } | Should -Throw '*Not found*'
        }
    }
}
