Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMTagTopTag: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMTagTopTag')
    }

    It 'Should contain an output type of PowerLFM.Tag.TopTags' {
        $command.OutputType.Name -contains 'PowerLFM.Tag.TopTags' | Should -BeTrue
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets
    }
}

InModuleScope PowerLFM {

    Describe 'Get-LFMTagTopTag: Unit' -Tag Unit {

        Context 'Input' {

        }

        Context 'Execution' {

        }

        Context 'Output' {

        }
    }
}

Describe 'Get-LFMTagTopTag: Integration' -Tag Integration {

}

