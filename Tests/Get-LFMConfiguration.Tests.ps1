Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMConfiguration: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMConfiguration')
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets
    }
}

InModuleScope PowerLFM {

    Describe 'Get-LFMConfiguration: Unit' -Tag Unit {

        Context 'Input' {

        }

        Context 'Execution' {

        }

        Context 'Output' {

        }
    }
}

Describe 'Get-LFMConfiguration: Integration' -Tag Integration {

}

