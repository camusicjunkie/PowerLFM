
Describe 'Get-LFMChartTopArtist: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMChartTopArtist'.ChartTopArtist

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

        It 'Should throw when limit is greater than 119' {
            { Get-LFMChartTopArtist -Limit 120 } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends chart.getTopArtists as an unsigned GET' {
            $null = Get-LFMChartTopArtist -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'chart.getTopArtists'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the limit and page' {
            $null = Get-LFMChartTopArtist -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMChartTopArtist
        }

        It 'Should return the correct first top artist name' {
            $output[0].Artist | Should -Be $contextMock.Artists.Artist[0].Name
        }

        It 'Should return the correct first top artist id' {
            $output[0].Id | Should -Be $contextMock.Artists.Artist[0].Mbid
        }

        It 'Should return the correct first top artist listener count' {
            $output[0].Listeners | Should -BeOfType [int]
            $output[0].Listeners | Should -Be $contextMock.Artists.Artist[0].Listeners
        }

        It 'Should return the correct second top artist listener count' {
            $output[1].Listeners | Should -BeOfType [int]
            $output[1].Listeners | Should -Be $contextMock.Artists.Artist[1].Listeners
        }

        It 'Should return the correct second top artist url' {
            $output[1].Url | Should -Be $contextMock.Artists.Artist[1].Url
        }

        It 'Should return the correct second top artist play count' {
            $output[1].PlayCount | Should -BeOfType [int]
            $output[1].PlayCount | Should -Be $contextMock.Artists.Artist[1].PlayCount
        }

        It 'Chart should have two top artists' {
            $output.Artist | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMChartTopArtist } | Should -Throw '*Not found*'
        }
    }
}
