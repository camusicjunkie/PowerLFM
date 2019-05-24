Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe "Add-LFMAlbumTag" {

    Mock New-LFMAlbumSignature {} -ModuleName PowerLFM
    Mock Invoke-WebRequest {} -ModuleName PowerLFM
    Mock Write-Verbose {}

    Context "Parameter attribute validation" {
        $command = Get-Command -Name Add-LFMAlbumTag

        $testCases = @(
            @{'Name' = 'Album'}
            @{'Name' = 'Artist'}
            @{'Name' = 'Tag'}
        )

        It "Should have cmdletbinding declared" {
            $command.CmdletBinding | Should -BeTrue
        }

        It "<Name> parameter should be mandatory" -TestCases $testCases {
            param ($Name)
            $command.Parameters[$Name].Attributes.Mandatory | Should -BeTrue
        }

        It "<Name> parameter should accept value from pipeline by property name" -TestCases $testCases {
            param ($Name)
            $command.Parameters[$Name].Attributes.ValueFromPipelineByPropertyName | Should -BeTrue
        }
    }

    Context "Input" {
        It "Should throw when Album is null" {
            {Add-LFMAlbumTag -Album $null} | Should -Throw
        }

        It "Should throw when Tag has more than 10 values" {
            $aatParams = @{
                Album = 'Album'
                Artist = 'Artist'
                Tag = @(1..11)
            }
            {Add-LFMAlbumTag @aatParams} | Should -Throw
        }

        It "Should not throw when Tag has 1 to 10 values" {
            $aatParams = @{
                Album = 'Album'
                Artist = 'Artist'
                Tag = @(1..10)
            }
            {Add-LFMAlbumTag @aatParams} | Should -Not -Throw
        }
    }

    Context "Execution" {

    }

    Context "Output" {

    }
}
Describe "Add-LFMAlbumTag" -Tag Integration {

}
