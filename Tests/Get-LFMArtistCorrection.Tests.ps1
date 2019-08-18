Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMArtistCorrection: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMArtistCorrection')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Artist.Correction' {
        $command.OutputType.Name -contains 'PowerLFM.Artist.Correction' | Should -BeTrue
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [Artist] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Artist

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
                $parameter.IsMandatory | Should -BeTrue
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
    $contextMock = $mocks.'Get-LFMArtistCorrection'.ArtistCorrection

    Describe 'Get-LFMArtistCorrection: Unit' -Tag Unit {

        Context 'Input' {

            It 'Should throw when Artist is null' {
                {Get-LFMArtistCorrection -Artist $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Invoke-RestMethod
            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    gacParams = @{
                        Artist = 'Artist'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $gacParams)

                Get-LFMArtistCorrection @gacParams

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
                $script:output = Get-LFMArtistCorrection -Artist Artist
            }

            It 'Should output object of type PowerLFM.Artist.Correction' {
                $output.PSTypeNames[0] | Should -Be 'PowerLFM.Artist.Correction'
            }

            It "Artist should have corrected name of $($contextMock.corrections.correction.artist.name)" {
                $output.Artist | Should -Be $contextMock.corrections.correction.artist.name
            }

            It "Artist correction should have url of $($contextMock.corrections.correction.artist.url)" {
                $output.Url | Should -Be $contextMock.corrections.correction.artist.url
            }

            It "Artist correction should have id of $($contextMock.corrections.correction.artist.mbid)" {
                $output.Id | Should -Be $contextMock.corrections.correction.artist.mbid
            }

            It 'Artist should not have more than 1 correction' {
                $output.Artist | Should -Not -BeNullOrEmpty
                $output.Artist | Should -Not -HaveCount 2
            }
        }
    }
}

Describe 'Get-LFMArtistCorrection: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
