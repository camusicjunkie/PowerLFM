
Describe 'Get-LFMChartTopTag: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMChartTopTag'.ChartTopTag

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
            { Get-LFMChartTopTag -Limit 120 } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends chart.getTopTags as an unsigned GET' {
            $null = Get-LFMChartTopTag -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'chart.getTopTags'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the limit and page' {
            $null = Get-LFMChartTopTag -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMChartTopTag
        }

        It 'Should return the correct first top tag name' {
            $output[0].Tag | Should -Be $contextMock.Tags.Tag[0].Name
        }

        It 'Should return the correct first top tag total tags count' {
            $output[0].TotalTags | Should -Be $contextMock.Tags.Tag[0].Taggings
        }

        It 'Should return the correct first top tag reach' {
            $output[0].Reach | Should -BeOfType [int]
            $output[0].Reach | Should -Be $contextMock.Tags.Tag[0].reach
        }

        It 'Should return the correct second top tag reach' {
            $output[1].Reach | Should -BeOfType [int]
            $output[1].Reach | Should -Be $contextMock.Tags.Tag[1].reach
        }

        It 'Should return the correct second top tag url' {
            $output[1].Url | Should -Be $contextMock.Tags.Tag[1].Url
        }

        It 'Chart should have two top tags' {
            $output.Tag | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMChartTopTag } | Should -Throw '*Not found*'
        }
    }
}
