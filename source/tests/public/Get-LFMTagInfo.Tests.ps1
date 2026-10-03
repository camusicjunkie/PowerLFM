
Describe 'Get-LFMTagInfo: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTagInfo'.TagInfo

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
            { Get-LFMTagInfo -Tag $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends tag.getInfo as an unsigned GET' {
            $null = Get-LFMTagInfo -Tag 'Black Metal'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'tag.getInfo'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the tag as tag' {
            $null = Get-LFMTagInfo -Tag 'Black Metal'

            (Get-LFMRecordedRequest).Parameters['tag'] | Should -Be 'Black Metal'
        }

        It 'Sends the language as lang' {
            $null = Get-LFMTagInfo -Tag 'Black Metal' -Language 'en'

            (Get-LFMRecordedRequest).Parameters['lang'] | Should -Be 'en'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Tag = 'Tag1' }
                [pscustomobject] @{ Tag = 'Tag2' }
            ) | Get-LFMTagInfo

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['tag'] | Should -Be 'Tag2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMTagInfo -Tag Tag
        }

        It 'Should return the correct tag name' {
            $output.Tag | Should -Be $contextMock.Tag.Name
        }

        It 'Should return the correct total tags count' {
            $output.TotalTags | Should -Be $contextMock.Tag.total
        }

        It 'Should return the correct tag reach' {
            $output.Reach | Should -BeOfType [int]
            $output.Reach | Should -Be $contextMock.Tag.reach
        }

        It "Tag should have url of http://www.last.fm/tag/Tag" {
            $output.Url | Should -Be "http://www.last.fm/tag/Tag"
        }

        It 'Tag should have one tag' {
            $output.Tag | Should -HaveCount 1
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMTagInfo -Tag Tag } | Should -Throw '*Not found*'
        }
    }
}
