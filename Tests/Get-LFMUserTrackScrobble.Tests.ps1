Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserTrackScrobble: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserTrackScrobble')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.TrackScrobble' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.TrackScrobble'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

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

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
            }
        }

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

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [UserName] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq UserName

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

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }

        Context 'Parameter [Limit] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Limit

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

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 3" {
                $parameter.Position | Should -Be 3
            }
        }

        Context 'Parameter [Page] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Page

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

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 4" {
                $parameter.Position | Should -Be 4
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserTrackScrobble'.UserTrackScrobble

    Describe 'Get-LFMUserTrackScrobble: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when username is null" {
                {Get-LFMUserTrackScrobble -UserName $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 6
                    gutsParams = @{
                        Track = 'Track'
                        Artist = 'Artist'
                    }
                }
                @{
                    times = 6
                    gutsParams = @{
                        Track = 'Track'
                        Artist = 'Artist'
                        UserName = 'UserName'
                    }
                }
                @{
                    times = 7
                    gutsParams = @{
                        Track = 'Track'
                        Artist = 'Artist'
                        UserName = 'UserName'
                        Limit = '5'
                    }
                }
                @{
                    times = 8
                    gutsParams = @{
                        Track = 'Track'
                        Artist = 'Artist'
                        UserName = 'UserName'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $gutsParams)

                Get-LFMUserTrackScrobble @gutsParams

                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = $times
                    Scope = 'It'
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            Mock Invoke-RestMethod {$contextMock}
            Mock ConvertFrom-UnixTime {$mocks.UnixTime.From}

            $output = Get-LFMUserTrackScrobble -Track Track -Artist Artist -UserName camusicjunkie

            It "User first scrobbled track should have a name of $($contextMock.TrackScrobbles.Track[0].Name)" {
                $output[0].Track | Should -Be $contextMock.TrackScrobbles.Track[0].Name
            }

            It "User first scrobbled track should have artist name of $($contextMock.TrackScrobbles.Track[0].Artist.'#text')" {
                $output[0].Artist | Should -Be $contextMock.TrackScrobbles.Track[0].Artist.'#text'
            }

            It "User first scrobbled track should have track id with a value of $($contextMock.TrackScrobbles.Track[0].Mbid)" {
                $output[0].TrackId | Should -Be $contextMock.TrackScrobbles.Track[0].Mbid
            }

            It "User should have scrobbled track on $($mocks.UnixTime.From)" {
                $output[0].Date | Should -Be $mocks.UnixTime.From
            }

            It "User second scrobbled track should have track url of $($contextMock.TrackScrobbles.Track[1].Url)" {
                $output[1].TrackUrl | Should -Be $contextMock.TrackScrobbles.Track[1].Url
            }

            It "User second scrobbled track should have artist name of $($contextMock.TrackScrobbles.Track[1].Album.'#text')" {
                $output[1].Album | Should -Be $contextMock.TrackScrobbles.Track[1].Album.'#text'
            }

            It 'User should have two scrobbled tracks' {
                $output.Track | Should -HaveCount 2
            }

            It 'User should not have more than two scrobbled tracks' {
                $output.Track | Should -Not -BeNullOrEmpty
                $output.Track | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMUserTrackScrobble: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
