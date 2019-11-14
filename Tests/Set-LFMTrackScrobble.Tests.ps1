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

        BeforeAll {
            $script:dateTime = New-MockObject -Type 'datetime'
        }

        Mock Remove-CommonParameter {
            [hashtable] @{
                Artist = 'Artist'
                Track  = 'Track'
                Timestamp = $dateTime
            }
        }
        Mock ConvertTo-LFMParameter
        Mock Get-LFMSignature
        Mock New-LFMApiQuery
        Mock Invoke-LFMApiUri
        Mock Get-LFMIgnoredMessage { @{ Code = 0 } }

        Context 'Input' {
            It 'Should throw when artist is null' {
                {Set-LFMTrackScrobble -Artist $null} | Should -Throw
            }

            It 'Should throw when track is null' {
                {Set-LFMTrackScrobble -Track $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime

            It "Should remove common parameters from bound parameters" {
                $amParams = @{
                    CommandName = 'Remove-CommonParameter'
                    Exactly     = $true
                    Times       = 1
                    ParameterFilter = {
                        $PSBoundParameters
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should create a signature from the parameters passed in' {
                $amParams = @{
                    CommandName     = 'Get-LFMSignature'
                    Exactly         = $true
                    Times           = 1
                    ParameterFilter = {
                        $Artist -eq 'Artist' -and
                        $Track -eq 'Track' -and
                        $Timestamp -eq $dateTime -and
                        $Method -eq 'track.scrobble'
                    }
                }
                Assert-MockCalled @amParams
            }

            It "Should convert parameters to format API expects after signing" {
                $amParams = @{
                    CommandName = 'ConvertTo-LFMParameter'
                    Exactly     = $true
                    Times       = 1
                }
                Assert-MockCalled @amParams
            }

            It "Should take hashtable and build a query for a uri" {
                $amParams = @{
                    CommandName = 'New-LFMApiQuery'
                    Exactly     = $true
                    Times       = 1
                }
                Assert-MockCalled @amParams
            }

            It "Should check to see if the response has not been filtered" {
                $amParams = @{
                    CommandName = 'Get-LFMIgnoredMessage'
                    Exactly     = $true
                    Times       = 1
                    ParameterFilter = {
                        $Code -eq 0
                    }
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            It 'Should send proper output when -Whatif is used' {
                $output = Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Setting track to now playing" on target "Track: Track".'
            }

            It "Should output an object when -PassThru is used" {
                Mock Invoke-LFMApiUri { $contextMock }

                $output = Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime -PassThru
                $output.Artist | Should -Be $contextMock.Scrobbles.Scrobble.Artist.'#text'
                $output.Album | Should -Be $contextMock.Scrobbles.Scrobble.Album.'#text'
                $output.Track | Should -Be $contextMock.Scrobbles.Scrobble.Track.'#text'
            }

            It "Should throw when ignored message code is 1" {
                Mock Get-LFMIgnoredMessage { @{ Code = 1; Message = 'Filtered message' } }

                { Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime } | Should -Throw 'Filtered message'
            }

            It "Should throw when an error is returned in the response" {
                Mock Invoke-LFMApiUri { throw 'Error' }

                { Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime } | Should -Throw 'Error'
            }
        }
    }
}

Describe 'Set-LFMTrackScrobble: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
