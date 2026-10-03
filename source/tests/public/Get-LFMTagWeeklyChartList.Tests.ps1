
Describe 'Get-LFMTagWeeklyChartList: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTagWeeklyChartList'.TagWeeklyChartList

        Mock ConvertFrom-UnixTime -ModuleName 'PowerLFM'

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

        It 'Should throw when tag is null' {
            { Get-LFMTagWeeklyChartList -Tag $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends tag.getWeeklyChartList as an unsigned GET' {
            $null = Get-LFMTagWeeklyChartList -Tag 'Black Metal'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'tag.getWeeklyChartList'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the tag as tag' {
            $null = Get-LFMTagWeeklyChartList -Tag 'Black Metal'

            (Get-LFMRecordedRequest).Parameters['tag'] | Should -Be 'Black Metal'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Tag = 'Tag1' }
                [pscustomobject] @{ Tag = 'Tag2' }
            ) | Get-LFMTagWeeklyChartList

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['tag'] | Should -Be 'Tag2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMTagWeeklyChartList -Tag Tag
        }

        It 'Tag should have two charts' {
            $output | Should -HaveCount 1
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

            { Get-LFMTagWeeklyChartList -Tag Tag } | Should -Throw '*Not found*'
        }
    }
}
