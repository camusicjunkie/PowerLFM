Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Set-LFMTrackUnlove: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command 'Set-LFMTrackUnlove')
    }

    It 'Contains an output type of PowerLFM.Track.Unlove' {
        $command.OutputType.Name -contains 'PowerLFM.Track.Unlove' | Should -BeTrue
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object { $_.'Name' -eq '__AllParameterSets' }

        Context 'Parameter [Artist] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object { $_.'Name' -eq 'Artist' }

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

            $parameter = $parameterSet.Parameters | Where-Object { $_.'Name' -eq 'Track' }

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

    Describe 'Set-LFMTrackUnlove: Unit' -Tag Unit {
        Mock Get-LFMTrackSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

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
                $output | Should -Match 'Performing the operation "Removing love" on target "Track: Track".'
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

        #Calls to Start-Sleep are to allow enough time for track to be unloved
        It "Track should be loved for a user before unloving it" {
            Start-Sleep -Seconds 1.5

            $track = Get-LFMTrackInfo @gtiParams
            $track.Loved | Should -Be 'Yes'
        }

        It "Track should be unloved for a user" {
            Set-LFMTrackUnlove @stlParams

            Start-Sleep -Seconds 1.5

            $track = Get-LFMTrackInfo @gtiParams
            $track.Loved | Should -Be 'No'
        }
    }
}
