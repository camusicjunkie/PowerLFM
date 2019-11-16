Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserFriend: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserFriend')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.Info' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.Info'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [UserName] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq UserName

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [Limit] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Limit

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.Int32" {
                $parameter.ParameterType.ToString() | Should -Be System.Int32
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [Page] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Page

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.Int32" {
                $parameter.ParameterType.ToString() | Should -Be System.Int32
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserFriend'.UserFriend

    Describe 'Get-LFMUserFriend: Unit' -Tag Unit {

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        }
        Mock ConvertTo-LFMParameter
        Mock New-LFMApiQuery
        Mock Invoke-LFMApiUri {$contextMock}
        Mock ConvertFrom-UnixTime

        Context 'Input' {

            It 'Should throw when username is null' {
                {Get-LFMUserFriend -UserName $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Get-LFMUserFriend

            It "Should remove common parameters from bound parameters" {
                $amParams = @{
                    CommandName     = 'Remove-CommonParameter'
                    Exactly         = $true
                    Times           = 1
                    ParameterFilter = {
                        $PSBoundParameters
                    }
                }
                Assert-MockCalled @amParams
            }

            It "Should convert parameters to format API expects after signing" {
                $amParams = @{
                    CommandName = 'ConvertTo-LFMParameter'
                    Exactly     = $true
                    Times       = 1
                }
                Assert-MockCalled @amParams
            }

            It "Should take hashtable and build a query for a uri" {
                $amParams = @{
                    CommandName = 'New-LFMApiQuery'
                    Exactly     = $true
                    Times       = 1
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            $output = Get-LFMUserFriend

            It "User first friend should have a name of $($contextMock.Friends.User[0].RealName)" {
                $output[0].RealName | Should -Be $contextMock.Friends.User[0].RealName
            }

            It "User first friend should have a username of $($contextMock.Friends.User[0].Name)" {
                $output[0].UserName | Should -Be $contextMock.Friends.User[0].Name
            }

            It "User first friend should have $($contextMock.Friends.User[0].PlayLists) playlists" {
                $output[0].PlayLists | Should -Be $contextMock.Friends.User[0].PlayLists
            }

            It "User second friend should have a url of $($contextMock.Friends.User[1].Url)" {
                $output[1].Url | Should -Be $contextMock.Friends.User[1].Url
            }

            It "User second friend should have registered in $($contextMock.Friends.User[1].Country)" {
                $output[1].Country | Should -Be $contextMock.Friends.User[1].Country
            }

            It 'User should have two friends' {
                $output.RealName | Should -HaveCount 2
            }

            It 'User should not have more than two friends' {
                $output.RealName | Should -Not -BeNullOrEmpty
                $output.RealName | Should -Not -HaveCount 3
            }

            It 'Should call the correct Last.fm get method' {
                Get-LFMUserFriend

                $amParams = @{
                    CommandName = 'Invoke-LFMApiUri'
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                    ParameterFilter = {
                        $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should convert the date from unix time to the local time' {
                Get-LFMUserFriend

                $amParams = @{
                    CommandName = 'ConvertFrom-UnixTime'
                    Exactly = $true
                    Times = 2
                    Scope = 'It'
                    ParameterFilter = {
                        $UnixTime -eq 0 -or
                        $UnixTime -eq 60 -and
                        $Local -eq $true
                    }
                }
                Assert-MockCalled @amParams
            }

            It "Should throw when an error is returned in the response" {
                Mock Invoke-LFMApiUri { throw 'Error' }

                { Get-LFMUserFriend } | Should -Throw 'Error'
            }
        }
    }
}

Describe 'Get-LFMUserFriend: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
