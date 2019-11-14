Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Set-LFMTrackLove: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Set-LFMTrackLove')
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
    }
}

InModuleScope PowerLFM {

    Describe 'Set-LFMTrackLove: Unit' -Tag Unit {

        Mock Remove-CommonParameter {
            [hashtable] @{
                Artist = 'Artist'
                Track = 'Track'
            }
        }
        Mock ConvertTo-LFMParameter
        Mock Get-LFMSignature
        Mock New-LFMApiQuery
        Mock Invoke-LFMApiUri
        Mock Get-LFMIgnoredMessage { @{ Code = 0 } }

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

            Set-LFMTrackLove -Artist Artist -Track Track -Confirm:$false

            It "Should remove common parameters from bound parameters" {
                $amParams = @{
                    CommandName     = 'Remove-CommonParameter'
                    Exactly         = $true
                    Times           = 1
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
                        $Method -eq 'track.love'
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
        }

        Context 'Output' {

            It 'Should call the correct Last.fm post method' {
                Set-LFMTrackLove -Artist Artist -Track Track -Confirm:$false

                $amParams = @{
                    CommandName = 'Invoke-LFMApiUri'
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                    ParameterFilter = {
                        $Method -eq 'Post' -and
                        $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should send proper output when -Whatif is used' {
                $output = Set-LFMTrackLove -Artist Artist -Track Track -Confirm:$false -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Adding love" on target "Track: Track".'
            }

            It "Should throw when an error is returned in the response" {
                Mock Invoke-LFMApiUri { throw 'Error' }

                { Set-LFMTrackLove -Artist Artist -Track Track -Confirm:$false } | Should -Throw 'Error'
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
            # do/until loop is allowing for track love/unlove to finish
            $i = 0
            do {
                $track = Get-LFMTrackInfo @gtiParams
                $i += .25
            } until ($track.loved -eq 'No' -or $i -eq 5)

            if ($i -ge 5) {Set-ItResult -Inconclusive -Because 'the API call timed out'}

            $track.Loved | Should -Be 'No'
        }

        It "Track should be loved for a user" {
            # do/until loop is allowing for track love/unlove to finish
            Set-LFMTrackLove @stlParams

            $i = 0
            do {
                $track = Get-LFMTrackInfo @gtiParams
                $i += .25
            } until ($track.loved -eq 'Yes' -or $i -eq 5)

            if ($i -ge 5) {Set-ItResult -Inconclusive -Because 'the API call timed out'}

            $track.Loved | Should -Be 'Yes'
        }
    }
}
