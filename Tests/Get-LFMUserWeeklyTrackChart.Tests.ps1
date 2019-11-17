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
            $command.ParameterSets.Name | Should -Contain '__AllParameterSets'
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

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        }
        Mock ConvertTo-LFMParameter
        Mock New-LFMApiQuery
        Mock Invoke-LFMApiUri {$contextMock}

        Context 'Input' {

            It 'Should throw when username is null' {
                {Get-LFMUserWeeklyTrackChart -UserName $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Get-LFMUserWeeklyTrackChart

            It 'Should remove common parameters from bound parameters' {
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

            It 'Should convert parameters to format API expects after signing' {
                $amParams = @{
                    CommandName = 'ConvertTo-LFMParameter'
                    Exactly     = $true
                    Times       = 1
                }
                Assert-MockCalled @amParams
            }

            It 'Should take hashtable and build a query for a uri' {
                $amParams = @{
                    CommandName = 'New-LFMApiQuery'
                    Exactly     = $true
                    Times       = 1
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            $output = Get-LFMUserWeeklyTrackChart

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

            It 'Should call the correct Last.fm get method' {
                $amParams = @{
                    CommandName = 'Invoke-LFMApiUri'
                    Exactly = $true
                    Times = 1
                    Scope = 'Context'
                    ParameterFilter = {
                        $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should throw when an error is returned in the response' {
                Mock Invoke-LFMApiUri { throw 'Error' }

                { Get-LFMUserWeeklyTrackChart } | Should -Throw 'Error'
            }
        }
    }
}
