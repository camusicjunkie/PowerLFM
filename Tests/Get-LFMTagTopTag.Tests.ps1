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

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        }
        Mock ConvertTo-LFMParameter
        Mock New-LFMApiQuery
        Mock Invoke-LFMApiUri {$contextMock}

        Context 'Execution' {

            Get-LFMTagTopTag

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

            $output = Get-LFMTagTopTag

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

            It 'Should call the correct Last.fm get method' {
                Get-LFMTagTopTag

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

            It "Should throw when an error is returned in the response" {
                Mock Invoke-LFMApiUri { throw 'Error' }

                { Get-LFMTagTopTag } | Should -Throw 'Error'
            }
        }
    }
}

Describe 'Get-LFMTagTopTag: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
