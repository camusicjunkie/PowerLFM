Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserWeeklyChartList: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserWeeklyChartList')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.WeeklyChartList' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.WeeklyChartList'
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
                $parameter.Position | Should -Be 0
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserWeeklyChartList'.UserWeeklyChartList

    Describe 'Get-LFMUserWeeklyChartList: Unit' -Tag Unit {

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        }
        Mock ConvertTo-LFMParameter
        Mock New-LFMApiQuery
        Mock Invoke-LFMApiUri {$contextMock}
        Mock ConvertFrom-UnixTime

        Context 'Input' {

            It 'Should throw when username is null' {
                {Get-LFMUserWeeklyChartList -UserName $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Get-LFMUserWeeklyChartList

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

            Get-LFMUserWeeklyChartList

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

            It 'Should convert the date from unix time to the local time' {
                $amParams = @{
                    CommandName = 'ConvertFrom-UnixTime'
                    Exactly = $true
                    Times = 2
                    Scope = 'Context'
                    ParameterFilter = {
                        $UnixTime -eq 0 -or
                        $UnixTime -eq 60 -and
                        $Local -eq $true
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should throw when an error is returned in the response' {
                Mock Invoke-LFMApiUri { throw 'Error' }

                { Get-LFMUserWeeklyChartList } | Should -Throw 'Error'
            }
        }
    }
}
