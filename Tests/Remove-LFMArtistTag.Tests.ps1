Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

InModuleScope PowerLFM {
    Describe 'Remove-LFMArtistTag: Unit' -Tag Unit {
        Mock Get-LFMArtistSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

        Context 'Parameter attribute validation' {
            $command = Get-Command -Name Remove-LFMArtistTag

            $testCases = @(
                @{Name = 'Artist'}
                @{Name = 'Tag'}
            )

            It 'Should have cmdletbinding declared' {
                $command.CmdletBinding | Should -BeTrue
            }

            It '<Name> parameter should be mandatory' -TestCases $testCases {
                param ($Name)
                $command.Parameters[$Name].Attributes.Mandatory | Should -BeTrue
            }

            It '<Name> parameter should accept value from pipeline by property name' -TestCases $testCases {
                param ($Name)
                $command.Parameters[$Name].Attributes.ValueFromPipelineByPropertyName | Should -BeTrue
            }
        }

        Context 'Input' {
            It 'Should throw when Album is null' {
                {Remove-LFMArtistTag -Album $null} | Should -Throw
            }

            It 'Should throw when Tag has more than 1 value' {
                $aatParams = @{
                    Artist = 'Artist'
                    Tag = @(1..2)
                }
                {Remove-LFMArtistTag @aatParams} | Should -Throw
            }
        }

        Context 'Execution' {
            Mock ForEach-Object

            $aatParams = @{
                Artist = 'Artist'
                Tag = 'Tag'
                Confirm = $false
            }
            Remove-LFMArtistTag @aatParams

            It 'Should create a signature from the parameters passed in' {
                $amParams = @{
                    CommandName = 'Get-LFMArtistSignature'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Artist -eq 'Artist' -and
                        $Tag -eq 'Tag' -and
                        $Method -eq 'artist.removeTag'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should loop through each parameter in url string' {
                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = 6
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {
            $aatParams = @{
                Artist = 'Artist'
                Tag = 'Tag'
                Confirm = $false
            }

            It 'Should call the Last.fm Rest API for album.removeTag post method' {
                Remove-LFMArtistTag @aatParams

                $amParams = @{
                    CommandName = 'Invoke-WebRequest'
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                    ParameterFilter = {
                        $Method -eq 'Post'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should send proper output when -Whatif is used' {
                $output = Remove-LFMArtistTag @aatParams -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Removing artist tag: Tag" on target "Artist: Artist".'
            }

            It 'Should send verbose output when -Verbose is used' {
                Remove-LFMArtistTag @aatParams -Verbose 4>&1

                $amParams = @{
                    CommandName = 'Write-Verbose'
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @amParams
            }
        }
    }
}

Describe 'Remove-LFMArtistTag: Integration' -Tag Integration {

    BeforeAll {
        Get-LFMConfiguration

        $atParams = @{
            Artist = 'Deftones'
            Tag = 'randomValue'
            Confirm = $false
        }
        Add-LFMArtistTag @atParams
    }

    It "Should contain the random value tag before removing it" {
        $tag = Get-LFMArtistTag -Artist Deftones
        $tag.Tag | Should -Contain 'randomValue'
    }

    It "Should remove the new random value tag from the artist" {
        Remove-LFMArtistTag @atParams
        $tag = Get-LFMArtistTag -Artist Deftones
        @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -BeNullOrEmpty
        @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -Not -Be 'randomValue'
    }
}