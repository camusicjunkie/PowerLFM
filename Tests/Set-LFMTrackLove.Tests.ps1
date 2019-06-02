Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

InModuleScope PowerLFM {
    Describe 'Set-LFMTrackLove: Unit' -Tag Unit {
        Mock Get-LFMTrackSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

        Context 'Parameter attribute validation' {
            $command = Get-Command -Name Set-LFMTrackLove

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
                {Set-LFMTrackLove -Artist $null} | Should -Throw
            }

            It 'Should throw when Track has more than 1 value' {
                $aatParams = @{
                    Artist = 'Artist'
                    Track = @(1..2)
                }
                {Set-LFMTrackLove @aatParams} | Should -Throw
            }
        }

        Context 'Execution' {
            Mock ForEach-Object

            $aatParams = @{
                Artist = 'Artist'
                Track = 'Track'
                Confirm = $false
            }
            Set-LFMTrackLove @aatParams

            It 'Should create a signature from the parameters passed in' {
                $amParams = @{
                    CommandName = 'Get-LFMTrackSignature'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Artist -eq 'Artist' -and
                        $Track -eq 'Track' -and
                        $Method -eq 'track.love'
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
                Set-LFMTrackLove @aatParams

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
                $output = Set-LFMTrackLove @aatParams -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Adding love" on target "Track: Track".'
            }

            It 'Should send verbose output when -Verbose is used' {
                Set-LFMTrackLove @aatParams -Verbose 4>&1

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

Describe 'Set-LFMTrackLove: Integration' -Tag Integration {

    BeforeAll {
        Get-LFMConfiguration

        $stlParams = @{
            Artist = 'Deftones'
            Track = 'Pink Cellphone'
            Confirm = $false
        }
        Set-LFMTrackUnlove @stlParams
        Set-LFMTrackLove @stlParams
    }

    Context "Rest API calls" {
        $gtiParams = @{
            Artist = 'Deftones'
            Track = 'Pink Cellphone'
            UserName = 'camusicjunkie'
        }

        It "Track should be loved for a user" {
            #Gives extra time for track to be loved
            Start-Sleep -Seconds 1

            $track = Get-LFMTrackInfo @gtiParams
            $track.Loved | Should -Be 'Yes'
        }
    }

    AfterAll {
        Set-LFMTrackUnlove @stlParams
    }
}
