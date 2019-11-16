Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserWeeklyTrackChart: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserWeeklyTrackChart')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.WeeklyTrackChart' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.WeeklyTrackChart'
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

            It 'Should be of type System.String' {
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

            It 'Should have a position of 0' {
                $parameter.Position | Should -Be 2
            }
        }

        Context 'Parameter [StartDate] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq StartDate

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.DateTime' {
                $parameter.ParameterType.ToString() | Should -Be System.DateTime
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

            It 'Should have a position of 1' {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [EndDate] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq EndDate

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.DateTime' {
                $parameter.ParameterType.ToString() | Should -Be System.DateTime
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

            It 'Should have a position of 2' {
                $parameter.Position | Should -Be 1
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserWeeklyTrackChart'.UserWeeklyTrackChart

    Describe 'Get-LFMUserWeeklyTrackChart: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It 'Should throw when username is null' {
                {Get-LFMUserWeeklyTrackChart -UserName $null} | Should -Throw
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

                Get-LFMUserWeeklyTrackChart @guwacParams

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
                $script:output = Get-LFMUserWeeklyTrackChart -UserName camusicjunkie
            }

            It "User weekly track chart first track should have name of $($contextMock.WeeklyTrackChart.Track[0].Name)" {
                $output[0].Track | Should -Be $contextMock.WeeklyTrackChart.Track[0].Name
            }

            It "User weekly track chart first track should have name of $($contextMock.WeeklyTrackChart.Track[0].Mbid)" {
                $output[0].Id | Should -Be $contextMock.WeeklyTrackChart.Track[0].Mbid
            }

            It "User weekly track chart first track should have artist name of $($contextMock.WeeklyTrackChart.Track[0].Artist.'#Text')" {
                $output[0].Artist | Should -Be $contextMock.WeeklyTrackChart.Track[0].Artist.'#Text'
            }

            It "User weekly track chart first track should have url of $($contextMock.WeeklyTrackChart.Track[0].Url)" {
                $output[0].Url | Should -Be $contextMock.WeeklyTrackChart.Track[0].Url
            }

            It "User weekly track chart second track should have url of $($contextMock.WeeklyTrackChart.Track[1].Url)" {
                $output[1].Url | Should -Be $contextMock.WeeklyTrackChart.Track[1].Url
            }

            It "User weekly track chart second track should have artist id with a value of $($contextMock.WeeklyTrackChart.Track[1].Artist.Mbid)" {
                $output[1].ArtistId | Should -Be $contextMock.WeeklyTrackChart.Track[1].Artist.Mbid
            }

            It "User weekly track chart second track should have a playcount of $($contextMock.WeeklyTrackChart.Track[1].PlayCount)" {
                $output[1].PlayCount | Should -Be $contextMock.WeeklyTrackChart.Track[1].PlayCount
            }

            It 'User weekly album chart should have two albums' {
                $output.Album | Should -HaveCount 2
            }

            It 'User weekly album chart should not have more than two albums' {
                $output.Album | Should -Not -BeNullOrEmpty
                $output.Album | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMUserWeeklyTrackChart: Integration' -Tag Integration {

    It 'Integration test' {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
