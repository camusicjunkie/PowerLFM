Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Set-LFMTrackScrobble: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Set-LFMTrackScrobble')
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

            It 'ValueFromRemainingArguments should be set to False' {
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

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [Timestamp] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Timestamp

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.DateTime" {
                $parameter.ParameterType.ToString() | Should -Be System.DateTime
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

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }

        Context 'Parameter [Album] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Album

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 3" {
                $parameter.Position | Should -Be 3
            }
        }

        Context 'Parameter [Id] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Id

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.Guid" {
                $parameter.ParameterType.ToString() | Should -Be System.Guid
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 4" {
                $parameter.Position | Should -Be 4
            }
        }

        Context 'Parameter [TrackNumber] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq TrackNumber

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.Int32" {
                $parameter.ParameterType.ToString() | Should -Be System.Int32
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 5" {
                $parameter.Position | Should -Be 5
            }
        }

        Context 'Parameter [Duration] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Duration

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.Int32" {
                $parameter.ParameterType.ToString() | Should -Be System.Int32
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 6" {
                $parameter.Position | Should -Be 6
            }
        }

        Context 'Parameter [PassThru] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq PassThru

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.Management.Automation.SwitchParameter" {
                $parameter.ParameterType.ToString() | Should -Be System.Management.Automation.SwitchParameter
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of -2147483648" {
                $parameter.Position | Should -Be -2147483648
            }
        }
    }
}

InModuleScope PowerLFM {

    Describe 'Set-LFMTrackScrobble: Unit' -Tag Unit {

        Mock Get-LFMTrackSignature -RemoveParameterType 'Timestamp'
        Mock ConvertTo-UnixTime
        Mock Invoke-RestMethod
        Mock Get-LFMIgnoredMessage { @{Code = 0 } }
        Mock Write-Verbose

        Context 'Input' {
            It 'Should throw when artist is null' {
                {Set-LFMTrackScrobble -Artist $null} | Should -Throw
            }

            It 'Should throw when track is null' {
                {Set-LFMTrackScrobble -Track $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 8
                    stsParams = @{
                        Artist = 'Artist'
                        Track = 'Track'
                        Timestamp = (Get-Date)
                    }
                }
                @{
                    times = 9
                    stsParams = @{
                        Artist = 'Artist'
                        Track = 'Track'
                        Timestamp = (Get-Date)
                        Album = 'Album'
                    }
                }
                @{
                    times = 10
                    stsParams = @{
                        Artist = 'Artist'
                        Track = 'Track'
                        Timestamp = (Get-Date)
                        Album = 'Album'
                        Id = (New-Guid)
                    }
                }
                @{
                    times = 11
                    stsParams = @{
                        Artist = 'Artist'
                        Track = 'Track'
                        Timestamp = (Get-Date)
                        Album = 'Album'
                        Id = (New-Guid)
                        TrackNumber = 1
                    }
                }
                @{
                    times = 12
                    stsParams = @{
                        Artist = 'Artist'
                        Track = 'Track'
                        Timestamp = (Get-Date)
                        Album = 'Album'
                        Id = (New-Guid)
                        TrackNumber = 1
                        Duration = 60
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $stsParams)

                Set-LFMTrackScrobble @stsParams

                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = $times
                    Scope = 'It'
                }
                Assert-MockCalled @amParams
            }

            It 'Should create a signature from the parameters passed in' {
                Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp (Get-Date)

                $amParams = @{
                    CommandName = 'Get-LFMTrackSignature'
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                    ParameterFilter = {
                        $Artist -eq 'Artist' -and
                        $Track -eq 'Track' -and
                        $Method -eq 'track.scrobble'
                    }
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            $stsParams = @{
                Artist = 'Artist'
                Track = 'Track'
                Timestamp = (Get-Date)
            }

            It 'Should send proper output when -Whatif is used' {
                $output = Set-LFMTrackScrobble @stsParams -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Setting track to now playing" on target "Track: Track".'
            }

            It "Should throw when ignored message code is 1" {
                Mock Get-LFMIgnoredMessage {@{Code = 1}}

                {Set-LFMTrackScrobble @stsParams} | Should -Throw
            }
        }
    }
}

Describe 'Set-LFMTrackScrobble: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
