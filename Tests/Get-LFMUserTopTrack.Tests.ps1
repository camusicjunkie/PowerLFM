Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserTopTrack: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserTopTrack')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.TopTrack' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.TopTrack'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [UserName] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq UserName

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
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

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [TimePeriod] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq TimePeriod

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

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [Limit] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Limit

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

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }

        Context 'Parameter [Page] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Page

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
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserTopTrack'.UserTopTrack

    Describe 'Get-LFMUserTopTrack: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when username is null" {
                {Get-LFMUserTopTrack -UserName $null} | Should -Throw
            }

            It "Should throw when limit has more than 50 values" {
                Set-ItResult -Pending -Because 'the type needs to change on the limit parameter'

                $guttParams = @{
                    UserName = 'UserName'
                    Limit = @(1..51)
                }
                {Get-LFMUserTopTrack @guttParams} | Should -Throw
            }

            It "Should not throw when limit has 1 to 50 values" {
                Set-ItResult -Pending -Because 'the type needs to change on the limit parameter'

                $guttParams = @{
                    UserName = 'UserName'
                    Limit = @(1..50)
                }
                {Get-LFMUserTopTrack @guttParams} | Should -Not -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    guttParams = @{
                        UserName = 'UserName'
                    }
                }
                @{
                    times = 5
                    guttParams = @{
                        UserName = 'UserName'
                        TimePeriod = 'Overall'
                    }
                }
                @{
                    times = 6
                    guttParams = @{
                        UserName = 'UserName'
                        TimePeriod = 'Overall'
                        Limit = '5'
                    }
                }
                @{
                    times = 7
                    guttParams = @{
                        UserName = 'UserName'
                        TimePeriod = 'Overall'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $guttParams)

                Get-LFMUserTopTrack @guttParams

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

            BeforeEach {
                $script:output = Get-LFMUserTopTrack -UserName camusicjunkie
            }

            It "User first top track should have track name of $($contextMock.TopTracks.Track[0].Name)" {
                $output[0].Track | Should -Be $contextMock.TopTracks.Track[0].Name
            }

            It "User first top track should have artist name of $($contextMock.TopTracks.Track[0].Artist.Name)" {
                $output[0].Artist | Should -Be $contextMock.TopTracks.Track[0].Artist.Name
            }

            It "User first top track should have playcount with a value of $($contextMock.TopTracks.Track[0].Playcount)" {
                $output[0].Playcount | Should -BeOfType [int]
                $output[0].Playcount | Should -Be $contextMock.TopTracks.Track[0].Playcount
            }

            It "User second top track should have playcount with a value of $($contextMock.TopTracks.Track[1].Playcount)" {
                $output[1].Playcount | Should -BeOfType [int]
                $output[1].Playcount | Should -Be $contextMock.TopTracks.Track[1].Playcount
            }

            It "User second top track should have artist id with a value of $($contextMock.TopTracks.Track[1].Artist.Mbid)" {
                $output[1].ArtistId | Should -Be $contextMock.TopTracks.Track[1].Artist.Mbid
            }

            It "User second top track should have artist url of $($contextMock.TopTracks.Track[1].Artist.Url)" {
                $output[1].ArtistUrl | Should -Be $contextMock.TopTracks.Track[1].Artist.Url
            }

            It "User second top track should have track url of $($contextMock.TopTracks.Track[1].Url)" {
                $output[1].TrackUrl | Should -Be $contextMock.TopTracks.Track[1].Url
            }

            It 'User should have two top tracks' {
                $output.Track | Should -HaveCount 2
            }

            It 'User should not have more than two top tracks' {
                $output.Track | Should -Not -BeNullOrEmpty
                $output.Track | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMUserTopTrack: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
