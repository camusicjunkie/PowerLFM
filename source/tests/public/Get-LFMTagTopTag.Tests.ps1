
Describe 'Get-LFMTagTopTag: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTagTopTag'.TagTopTag

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

    Context 'Request' {

        It 'Sends tag.getTopTags as an unsigned GET' {
            $null = Get-LFMTagTopTag

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'tag.getTopTags'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends no parameters of its own' {
            $null = Get-LFMTagTopTag

            $names = (Get-LFMRecordedRequest).Parameters.Keys | Sort-Object
            $names | Should -Be @('api_key', 'format', 'method')
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMTagTopTag
        }

        It 'Should return the correct first top tag name' {
            $output[0].Tag | Should -Be $contextMock.TopTags.Tag[0].Name
        }

        It 'Should return the correct first top tag reach' {
            $output[0].Reach | Should -Be $contextMock.TopTags.Tag[0].Reach
        }

        It 'Should return the correct first top tag count' {
            $output[0].Count | Should -Be $contextMock.TopTags.Tag[0].Count
        }

        It 'Should return the correct second top tag count' {
            $output[1].Count | Should -Be $contextMock.TopTags.Tag[1].Count
        }

        It 'Should return the correct second top tag reach' {
            $output[1].Reach | Should -Be $contextMock.TopTags.Tag[1].Reach
        }

        It 'Tag should have two top tags' {
            $output.Tag | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMTagTopTag } | Should -Throw '*Not found*'
        }
    }
}
