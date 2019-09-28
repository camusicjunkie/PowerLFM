Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserTopArtist: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserTopArtist')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.TopArtist' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.TopArtist'
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

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [TimePeriod] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq TimePeriod

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

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [Limit] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Limit

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

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }

        Context 'Parameter [Page] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Page

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

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 3" {
                $parameter.Position | Should -Be 3
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserTopArtist'.UserTopArtist

    Describe 'Get-LFMUserTopArtist: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when username is null" {
                {Get-LFMUserTopArtist -UserName $null} | Should -Throw
            }

            It "Should throw when limit has more than 50 values" {
                Set-ItResult -Pending -Because 'the type needs to change on the limit parameter'

                $gutaParams = @{
                    UserName = 'UserName'
                    Limit = @(1..51)
                }
                {Get-LFMUserTopArtist @gutaParams} | Should -Throw
            }

            It "Should not throw when limit has 1 to 50 values" {
                Set-ItResult -Pending -Because 'the type needs to change on the limit parameter'

                $gutaParams = @{
                    UserName = 'UserName'
                    Limit = @(1..50)
                }
                {Get-LFMUserTopArtist @gutaParams} | Should -Not -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    gutaParams = @{
                        UserName = 'UserName'
                    }
                }
                @{
                    times = 5
                    gutaParams = @{
                        UserName = 'UserName'
                        TimePeriod = 'Overall'
                    }
                }
                @{
                    times = 6
                    gutaParams = @{
                        UserName = 'UserName'
                        TimePeriod = 'Overall'
                        Limit = '5'
                    }
                }
                @{
                    times = 7
                    gutaParams = @{
                        UserName = 'UserName'
                        TimePeriod = 'Overall'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $gutaParams)

                Get-LFMUserTopArtist @gutaParams

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

            BeforeEach {
                $script:output = Get-LFMUserTopArtist -UserName camusicjunkie
            }

            It "User first top artist should have name of $($contextMock.TopArtists.Artist[0].Name)" {
                $output[0].Artist | Should -Be $contextMock.TopArtists.Artist[0].Name
            }

            It "User first top artist should have id of $($contextMock.TopArtists.Artist[0].Mbid)" {
                $output[0].Id | Should -Be $contextMock.TopArtists.Artist[0].Mbid
            }

            It "User second top artist should have url of $($contextMock.TopArtists.Artist[1].Url)" {
                $output[1].Url | Should -Be $contextMock.TopArtists.Artist[1].Url
            }

            It "User second top artist should have playcount with a value of $($contextMock.TopArtists.Artist[1].Playcount)" {
                $output[1].Playcount | Should -BeOfType [int]
                $output[1].Playcount | Should -Be $contextMock.TopArtists.Artist[1].Playcount
            }

            It 'User should have two top artists' {
                $output.Artist | Should -HaveCount 2
            }

            It 'User should not have more than two top artists' {
                $output.Artist | Should -Not -BeNullOrEmpty
                $output.Artist | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMUserTopArtist: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
