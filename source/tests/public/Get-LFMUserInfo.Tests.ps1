# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMUserInfo: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserInfo'.UserInfo

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
        Mock ConvertFrom-UnixTime -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should not throw when object is passed to the pipeline' {
            { [pscustomobject] @{ username = 'camusicjunkie' } | Get-LFMUserInfo } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserInfo
        }

        It 'Should remove common parameters from bound parameters' {
            $siParams = @{
                CommandName     = 'Remove-CommonParameter'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $PSBoundParameters
                }
            }
            Should -Invoke @siParams
        }

        It 'Should convert parameters to format API expects after signing' {
            $siParams = @{
                CommandName = 'ConvertTo-LFMParameter'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Should -Invoke @siParams
        }

        It 'Should take hashtable and build a query for a uri' {
            $siParams = @{
                CommandName = 'New-LFMApiQuery'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Should -Invoke @siParams
        }
    }

    Context 'Output' {

        BeforeAll {
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

        It 'Should call the correct Last.fm get method' {
            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Uri -like "$baseUrl*"
                }
            }
            Should -Invoke @siParams
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
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Get-LFMUserInfo } | Should -Throw 'Error'
        }
    }
}
