Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

InModuleScope PowerLFM {
    Describe 'Set-LFMTrackUnlove: Unit' -Tag Unit {
        Mock Get-LFMTrackSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

        Context 'Parameter attribute validation' {
            $command = Get-Command -Name Set-LFMTrackUnlove

            $testCases = @(
                @{Name = 'Artist'}
                @{Name = 'Track'}
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
            It 'Should throw when Artist is null' {
                {Set-LFMTrackUnlove -Artist $null} | Should -Throw
            }

            It 'Should throw when Track has more than 1 value' {
                $aatParams = @{
                    Artist = 'Artist'
                    Track = @(1..2)
                }
                {Set-LFMTrackUnlove @aatParams} | Should -Throw
            }
        }

        Context 'Execution' {
            Mock ForEach-Object

            $aatParams = @{
                Artist = 'Artist'
                Track = 'Track'
                Confirm = $false
            }
            Set-LFMTrackUnlove @aatParams

            It 'Should create a signature from the parameters passed in' {
                $amParams = @{
                    CommandName = 'Get-LFMTrackSignature'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Artist -eq 'Artist' -and
                        $Track -eq 'Track' -and
                        $Method -eq 'track.unlove'
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
                Track = 'Track'
                Confirm = $false
            }

            It 'Should call the Last.fm Rest API for track.love post method' {
                Set-LFMTrackUnlove @aatParams

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
                $output = Set-LFMTrackUnlove @aatParams -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Adding love" on target "Track: Track".'
            }

            It 'Should send verbose output when -Verbose is used' {
                Set-LFMTrackUnlove @aatParams -Verbose 4>&1

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

Describe 'Set-LFMTrackUnlove: Integration' -Tag Integration {

    BeforeAll {
        Get-LFMConfiguration

        $stlParams = @{
            Artist = 'Deftones'
            Track = 'Pink Cellphone'
            Confirm = $false
        }
        Set-LFMTrackLove @stlParams
    }

    Context "Rest API calls" {
        $gtiParams = @{
            Artist = 'Deftones'
            Track = 'Pink Cellphone'
            UserName = 'camusicjunkie'
        }

        It "Track should be loved for a user before unloving it" {
            Set-ItResult -Skipped -Because 'API is returning $null on calls with username'

            $track = Get-LFMTrackInfo @gtiParams
            $track.Loved | Should -Be 'No'
        }

        It "Track should be unloved for a user" {
            Set-ItResult -Skipped -Because 'API is returning $null on calls with username'

            Set-LFMTrackUnlove @stlParams
            #Needs to sleep to allow enough time for track to be unloved
            Start-Sleep -Seconds 1

            $track = Get-LFMTrackInfo @gtiParams
            $track.Loved | Should -Be 'Yes'
        }
    }
}
