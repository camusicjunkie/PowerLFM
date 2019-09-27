Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserInfo: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserInfo')
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

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserInfo'.UserInfo

    Describe 'Get-LFMUserInfo: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should not throw when object is passed to the pipeline" {
                {[pscustomobject] @{username = 'camusicjunkie'} | Get-LFMUserInfo} | Should -Not -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    guiParams = @{
                    }
                }
                @{
                    times = 4
                    guiParams = @{
                        UserName = 'UserName'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $guiParams)

                Get-LFMUserInfo @guiParams

                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = $times
                    Scope = 'It'
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            Mock Invoke-RestMethod {$contextMock}
            Mock ConvertFrom-UnixTime {$mocks.UnixTime.From}

            BeforeEach {
                $script:output = Get-LFMUserInfo
            }

            It "User should have a name of $($contextMock.User[0].RealName)" {
                $output[0].RealName | Should -Be $contextMock.User[0].RealName
            }

            It "User should have a username of $($contextMock.User[0].Name)" {
                $output[0].UserName | Should -Be $contextMock.User[0].Name
            }

            It "User should have a playcount of $($contextMock.User[0].PlayCount)" {
                $output[0].PlayCount | Should -Be $contextMock.User[0].PlayCount
            }

            It "User should have $($contextMock.User[0].PlayLists) playlists" {
                $output[0].PlayLists | Should -Be $contextMock.User[0].PlayLists
            }

            It "User should have registered on $($mocks.UnixTime.From)" {
                $output[0].Registered | Should -Be $mocks.UnixTime.From
            }

            It "User should have a url of $($contextMock.User[0].Url)" {
                $output[0].Url | Should -Be $contextMock.User[0].Url
            }

            It "User should have registered in $($contextMock.User[0].Country)" {
                $output[0].Country | Should -Be $contextMock.User[0].Country
            }
        }
    }
}

Describe 'Get-LFMUserInfo: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
