Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMTagTopTag: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMTagTopTag')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Tag.TopTags' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Tag.TopTags'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMTagTopTag'.TagTopTag

    Describe 'Get-LFMTagTopTag: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Execution' {

            Mock Foreach-Object

            It 'Should call Foreach-Object 3 times building url' {

                Get-LFMTagTopTag

                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = 3
                    Scope = 'It'
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            Mock Invoke-RestMethod {$contextMock}

            BeforeEach {
                $script:output = Get-LFMTagTopTag
            }

            It "Tag first top tag should have name of $($contextMock.TopTags.Tag[0].Name)" {
                $output[0].Tag | Should -Be $contextMock.TopTags.Tag[0].Name
            }

            It "Tag first top tag should have reach of $($contextMock.TopTags.Tag[0].Reach)" {
                $output[0].Reach | Should -Be $contextMock.TopTags.Tag[0].Reach
            }

            It "Tag first top tag should have count with a value of $($contextMock.TopTags.Tag[0].Count)" {
                $output[0].Count | Should -Be $contextMock.TopTags.Tag[0].Count
            }

            It "Tag second top tag should have count with a value of $($contextMock.TopTags.Tag[1].Count)" {
                $output[1].Count | Should -Be $contextMock.TopTags.Tag[1].Count
            }

            It "Tag second top tag should have reach with a value of $($contextMock.TopTags.Tag[1].Reach)" {
                $output[1].Reach | Should -Be $contextMock.TopTags.Tag[1].Reach
            }

            It 'Tag should have two top tags' {
                $output.Tag | Should -HaveCount 2
            }

            It 'Tag should not have more than two top tags' {
                $output.Tag | Should -Not -BeNullOrEmpty
                $output.Tag | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMTagTopTag: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
