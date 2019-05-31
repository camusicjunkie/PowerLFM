Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

InModuleScope PowerLFM {
    Describe 'Add-LFMTrackTag: Unit' -Tag Unit {
        Mock Get-LFMTrackSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

        Context 'Parameter attribute validation' {
            $command = Get-Command -Name Add-LFMTrackTag

            $testCases = @(
                @{Name = 'Track'}
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
            It 'Should throw when Track is null' {
                {Add-LFMTrackTag -Track $null} | Should -Throw
            }

            It 'Should throw when Tag has more than 10 values' {
                $aatParams = @{
                    Track = 'Track'
                    Artist = 'Artist'
                    Tag = @(1..11)
                }
                {Add-LFMTrackTag @aatParams} | Should -Throw
            }

            It 'Should not throw when Tag has 1 to 10 values' {
                $aatParams = @{
                    Track = 'Track'
                    Artist = 'Artist'
                    Tag = @(1..10)
                }
                {Add-LFMTrackTag @aatParams} | Should -Not -Throw
            }
        }

        Context 'Execution' {
            Mock ForEach-Object

            $aatParams = @{
                Track = 'Track'
                Artist = 'Artist'
                Tag = 'Tag'
            }
            Add-LFMTrackTag @aatParams

            It 'Should create a signature from the parameters passed in' {
                $amParams = @{
                    CommandName = 'Get-LFMTrackSignature'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Track -eq 'Track' -and
                        $Artist -eq 'Artist' -and
                        $Tag -eq 'Tag' -and
                        $Method -eq 'track.addTags'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should loop through each parameter in url string' {
                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = 7
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {
            $aatParams = @{
                Track = 'Track'
                Artist = 'Artist'
                Tag = 'Tag'
            }

            It 'Should call the Last.fm Rest API for track.addTags post method' {
                Add-LFMTrackTag @aatParams

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
                $output = Add-LFMTrackTag @aatParams -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Adding track tag: Tag" on target "Track: Track".'
            }

            It 'Should send verbose output when -Verbose is used' {
                Add-LFMTrackTag @aatParams -Verbose 4>&1

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

Describe 'Add-LFMTrackTag: Integration' -Tag Integration {

    BeforeAll {
        Get-LFMConfiguration

        $atParams = @{
            Track = 'Gore'
            Artist = 'Deftones'
            Tag = 'randomValue'
            Confirm = $false
        }
        Remove-LFMTrackTag @atParams
    }

    It "Should not contain the random value tag before adding it" {
        $tag = Get-LFMTrackTag -Track Gore -Artist Deftones
        $tag.Tag | Should -Not -Be 'randomValue'
    }

    It "Should add the new random value tag to the album" {
        Add-LFMTrackTag @atParams
        $tag = Get-LFMTrackTag -Track Gore -Artist Deftones
        @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -Not -BeNullOrEmpty
        @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -Be 'randomValue'
    }

    AfterAll {
        Remove-LFMTrackTag @atParams
    }
}
