
Describe 'Get-LFMUserPersonalTag: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserPersonalTag'.UserPersonalTag

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
            { Get-LFMUserPersonalTag -UserName $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            $guptParams = @{
                UserName = 'UserName'
                Tag      = 'Tag'
                TagType  = 'Artist'
                Limit    = 51
            }
            { Get-LFMUserPersonalTag @guptParams } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            $guptParams = @{
                UserName = 'UserName'
                Tag      = 'Tag'
                TagType  = 'Album'
                Limit    = 50
            }
            { Get-LFMUserPersonalTag @guptParams } | Should -Not -Throw
        }
    }

    Context 'Request' {

        It 'Sends user.getPersonalTags as an unsigned GET' {
            $null = Get-LFMUserPersonalTag -Tag 'rock' -TagType 'Artist' -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'user.getPersonalTags'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the tag, tag type and username' {
            $null = Get-LFMUserPersonalTag -Tag 'rock' -TagType 'Artist' -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Parameters['tag'] | Should -Be 'rock'
            $request.Parameters['taggingtype'] | Should -Be 'artist'
            $request.Parameters['user'] | Should -Be 'camusicjunkie'
        }

        It 'Sends the limit and page' {
            $null = Get-LFMUserPersonalTag -Tag 'rock' -TagType 'Artist' -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Tag = 'rock'; TagType = 'Artist' }
                [pscustomobject] @{ Tag = 'metal'; TagType = 'Artist' }
            ) | Get-LFMUserPersonalTag

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['tag'] | Should -Be 'metal'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMUserPersonalTag -Tag Tag -TagType Artist
        }

        It 'Should return the correct first personal tag artist name' {
            $output[0].Artist | Should -Be $contextMock.Taggings.Artists.Artist[0].Name
        }

        It 'Should return the correct first personal tag artist id' {
            $output[0].Id | Should -Be $contextMock.Taggings.Artists.Artist[0].Mbid
        }

        It 'Should return the correct second personal tag artist url' {
            $output[1].Url | Should -Be $contextMock.Taggings.Artists.Artist[1].Url
        }

        It 'User should have two personal tag artists' {
            $output.UserName | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMUserPersonalTag -Tag Tag -TagType Artist } | Should -Throw '*Not found*'
        }
    }
}
