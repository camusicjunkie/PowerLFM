Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Set-LFMTrackLove: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Set-LFMTrackLove')
    }

    It 'Should contain an output type of PowerLFM.Track.Love' {
        $command.OutputType.Name -contains 'PowerLFM.Track.Love' | Should -BeTrue
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [Artist] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Artist

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
                $parameter.IsMandatory | Should -BeTrue
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [Track] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Track

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
                $parameter.IsMandatory | Should -BeTrue
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }
    }
}

InModuleScope PowerLFM {

    Describe 'Set-LFMTrackLove: Unit' -Tag Unit {
        Mock Get-LFMTrackSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

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
    }

    Context "Rest API calls" {

        $gtiParams = @{
            Artist = 'Deftones'
            Track = 'Pink Cellphone'
            UserName = 'camusicjunkie'
        }

        It "Track should not be loved for a user before loving it" {
            $i = 0
            do {
                $track = Get-LFMTrackInfo @gtiParams
                $i += .25
            } until ($track.loved -eq 'No' -or $i -eq 5)

            $track.Loved | Should -Be 'No'
        }

        It "Track should be loved for a user" {
            Set-LFMTrackLove @stlParams

            $i = 0
            do {
                $track = Get-LFMTrackInfo @gtiParams
                $i += .25
            } until ($track.loved -eq 'Yes' -or $i -eq 5)

            $track.Loved | Should -Be 'Yes'
        }
    }
}
