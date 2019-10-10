Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserWeeklyArtistChart: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserWeeklyArtistChart')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.WeeklyArtistChart' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.WeeklyArtistChart'
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
                $parameter.Position | Should -Be 2
            }
        }

        Context 'Parameter [StartDate] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq StartDate

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

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [EndDate] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq EndDate

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

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 1
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserWeeklyArtistChart'.UserWeeklyArtistChart

    Describe 'Get-LFMUserWeeklyArtistChart: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when username is null" {
                {Get-LFMUserWeeklyArtistChart -UserName $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    guwacParams = @{
                        UserName = 'UserName'
                    }
                }
                @{
                    times = 5
                    guwacParams = @{
                        UserName = 'UserName'
                        StartDate = '1 Jan 1970'
                    }
                }
                @{
                    times = 6
                    guwacParams = @{
                        UserName = 'UserName'
                        StartDate = '1 Jan 1970'
                        EndDate = '2 Jan 1970'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $guwacParams)

                Get-LFMUserWeeklyArtistChart @guwacParams

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
                $script:output = Get-LFMUserWeeklyArtistChart -UserName camusicjunkie
            }

            It "User weekly artist chart first artist should have name of $($contextMock.WeeklyArtistChart.Artist[0].Name)" {
                $output[0].Artist | Should -Be $contextMock.WeeklyArtistChart.Artist[0].Name
            }

            It "User weekly artist chart first artist should have url of $($contextMock.WeeklyArtistChart.Artist[0].Url)" {
                $output[0].Url | Should -Be $contextMock.WeeklyArtistChart.Artist[0].Url
            }

            It "User weekly artist chart second artist should have url of $($contextMock.WeeklyArtistChart.Artist[1].Url)" {
                $output[1].Url | Should -Be $contextMock.WeeklyArtistChart.Artist[1].Url
            }

            It "User weekly artist chart second artist should have an id with a value of $($contextMock.WeeklyArtistChart.Artist[1].Mbid)" {
                $output[1].Id | Should -Be $contextMock.WeeklyArtistChart.Artist[1].Mbid
            }

            It "User weekly artist chart second artist should have a playcount of $($contextMock.WeeklyArtistChart.Artist[1].PlayCount)" {
                $output[1].PlayCount | Should -Be $contextMock.WeeklyArtistChart.Artist[1].PlayCount
            }

            It 'User weekly artist chart should have two artists' {
                $output.Artist | Should -HaveCount 2
            }

            It 'User weekly artist chart should not have more than two artists' {
                $output.Artist | Should -Not -BeNullOrEmpty
                $output.Artist | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMUserWeeklyArtistChart: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
