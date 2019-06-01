Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

InModuleScope PowerLFM {
    Describe 'Remove-LFMTrackTag: Unit' -Tag Unit {
        Mock Get-LFMTrackSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

        Context 'Parameter attribute validation' {
            $command = Get-Command -Name Remove-LFMTrackTag

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
                {Remove-LFMTrackTag -Track $null} | Should -Throw
            }

            It 'Should throw when Tag has more than 1 value' {
                $aatParams = @{
                    Track = 'Track'
                    Artist = 'Artist'
                    Tag = @(1..2)
                }
                {Remove-LFMTrackTag @aatParams} | Should -Throw
            }
        }

        Context 'Execution' {
            Mock ForEach-Object

            $aatParams = @{
                Track = 'Track'
                Artist = 'Artist'
                Tag = 'Tag'
                Confirm = $false
            }
            Remove-LFMTrackTag @aatParams

            It 'Should create a signature from the parameters passed in' {
                $amParams = @{
                    CommandName = 'Get-LFMTrackSignature'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Track -eq 'Track' -and
                        $Artist -eq 'Artist' -and
                        $Tag -eq 'Tag' -and
                        $Method -eq 'track.removeTag'
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
                Confirm = $false
            }

            It 'Should call the Last.fm Rest API for album.removeTag post method' {
                Remove-LFMTrackTag @aatParams

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
                $output = Remove-LFMTrackTag @aatParams -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Removing track tag: Tag" on target "Track: Track".'
            }

            It 'Should send verbose output when -Verbose is used' {
                Remove-LFMTrackTag @aatParams -Verbose 4>&1

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

Describe 'Remove-LFMTrackTag: Integration' -Tag Integration {

    BeforeAll {
        Get-LFMConfiguration

        $atParams = @{
            Track = 'Gore'
            Artist = 'Deftones'
            Tag = 'randomValue'
            Confirm = $false
        }
        Add-LFMTrackTag @atParams
    }

    It "Should contain the random value tag before removing it" {
        $tag = Get-LFMTrackTag -Artist Deftones -Track Gore
        $tag.Tag | Should -Contain 'randomValue'
    }

    It "Should remove the new random value tag from the artist" {
        Remove-LFMTrackTag @atParams
        $tag = Get-LFMTrackTag -Artist Deftones -Track Gore
        @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -BeNullOrEmpty
        @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -Not -Be 'randomValue'
    }
}
