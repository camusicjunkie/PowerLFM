
Describe 'Get-LFMUserInfo: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserInfo'.UserInfo

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

        It 'Should not throw when object is passed to the pipeline' {
            { [pscustomobject] @{ username = 'camusicjunkie' } | Get-LFMUserInfo } | Should -Not -Throw
        }
    }

    Context 'Request' {

        It 'Sends user.getInfo as an unsigned GET' {
            $null = Get-LFMUserInfo -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'user.getInfo'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the username as user' {
            $null = Get-LFMUserInfo -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Parameters['user'] | Should -Be 'camusicjunkie'
            $request.Parameters.ContainsKey('username') | Should -BeFalse
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ UserName = 'User1' }
                [pscustomobject] @{ UserName = 'User2' }
            ) | Get-LFMUserInfo

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['user'] | Should -Be 'User2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMUserInfo
        }

        It 'Should return the correct user real name' {
            $output[0].RealName | Should -Be $contextMock.User[0].RealName
        }

        It 'Should return the correct username' {
            $output[0].UserName | Should -Be $contextMock.User[0].Name
        }

        It 'Should return the correct user play count' {
            $output[0].PlayCount | Should -Be $contextMock.User[0].PlayCount
        }

        It 'Should return the correct user playlist count' {
            $output[0].PlayLists | Should -Be $contextMock.User[0].PlayLists
        }

        It 'Should return the correct user url' {
            $output[0].Url | Should -Be $contextMock.User[0].Url
        }

        It 'Should return the correct user country' {
            $output[0].Country | Should -Be $contextMock.User[0].Country
        }

        It 'Should convert the date from unix time to the local time' {
            $siParams = @{
                CommandName     = 'ConvertFrom-UnixTime'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
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

            { Get-LFMUserInfo } | Should -Throw '*Not found*'
        }
    }
}
