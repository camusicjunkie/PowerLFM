Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMLibraryArtist: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMLibraryArtist')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Library.Artist' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Library.Artist'
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
    $contextMock = $mocks.'Get-LFMLibraryArtist'.LibraryArtist

    Describe 'Get-LFMLibraryArtist: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when UserName is null" {
                {Get-LFMLibraryArtist -UserName $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    glaParams = @{
                        UserName = 'camusicjunkie'
                    }
                }
                @{
                    times = 5
                    glaParams = @{
                        UserName = 'camusicjunkie'
                        Limit = '5'
                    }
                }
                @{
                    times = 6
                    glaParams = @{
                        UserName = 'camusicjunkie'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $glaParams)

                Get-LFMLibraryArtist @glaParams

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
                $script:output = Get-LFMLibraryArtist -UserName camusicjunkie
            }

            It "Library first artist should have name of $($contextMock.Artists.Artist[0].Name)" {
                $output[0].Artist | Should -Be $contextMock.Artists.Artist[0].Name
            }

            It "Library first artist should have id of $($contextMock.Artists.Artist[0].Mbid)" {
                $output[0].Id | Should -Be $contextMock.Artists.Artist[0].Mbid
            }

            It "Library first artist should have playcount with a value of $($contextMock.Artists.Artist[0].Playcount)" {
                $output[0].Playcount | Should -BeOfType [int]
                $output[0].Playcount | Should -Be $contextMock.Artists.Artist[0].Playcount
            }

            It "Library second artist should have playcount with a value of $($contextMock.Artists.Artist[1].Playcount)" {
                $output[1].Playcount | Should -BeOfType [int]
                $output[1].Playcount | Should -Be $contextMock.Artists.Artist[1].Playcount
            }

            It "Library second artist should have track url of $($contextMock.Artists.Artist[1].Url)" {
                $output[1].Url | Should -Be $contextMock.Artists.Artist[1].Url
            }

            It 'Library should have two artists' {
                $output.Artist | Should -HaveCount 2
            }

            It 'Library should not have more than two artists' {
                $output.Artist | Should -Not -BeNullOrEmpty
                $output.Artist | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMLibraryArtist: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
