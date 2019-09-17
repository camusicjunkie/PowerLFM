Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserLovedTrack: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserLovedTrack')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.Track' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.Track'
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

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
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

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserLovedTrack'.UserLovedTrack

    Describe 'Get-LFMUserLovedTrack: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when username is null" {
                {Get-LFMUserLovedTrack -UserName $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    gultParams = @{
                        UserName = 'UserName'
                    }
                }
                @{
                    times = 5
                    gultParams = @{
                        UserName = 'UserName'
                        Limit = '5'
                    }
                }
                @{
                    times = 6
                    gultParams = @{
                        UserName = 'UserName'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $gultParams)

                Get-LFMUserLovedTrack @gultParams

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

            BeforeEach {
                $script:output = Get-LFMUserLovedTrack -UserName camusicjunkie
            }

            It "User first loved track should have a name of $($contextMock.LovedTracks.Track[0].Name)" {
                $output[0].Track | Should -Be $contextMock.LovedTracks.Track[0].Name
            }

            It "User first loved track should have artist name of $($contextMock.LovedTracks.Track[0].Artist.Name)" {
                $output[0].Artist | Should -Be $contextMock.LovedTracks.Track[0].Artist.Name
            }

            It "User first loved track should have track id with a value of $($contextMock.LovedTracks.Track[0].Mbid)" {
                $output[0].TrackId | Should -Be $contextMock.LovedTracks.Track[0].Mbid
            }

            It "User should have loved track on $($mocks.UnixTime.From)" {
                $output[0].Date | Should -Be $mocks.UnixTime.From
            }

            It "User second loved track should have artist id with a value of $($contextMock.LovedTracks.Track[1].Artist.Mbid)" {
                $output[1].ArtistId | Should -Be $contextMock.LovedTracks.Track[1].Artist.Mbid
            }

            It "User second loved track should have artist url of $($contextMock.LovedTracks.Track[1].Artist.Url)" {
                $output[1].ArtistUrl | Should -Be $contextMock.LovedTracks.Track[1].Artist.Url
            }

            It "User second loved track should have track url of $($contextMock.LovedTracks.Track[1].Url)" {
                $output[1].TrackUrl | Should -Be $contextMock.LovedTracks.Track[1].Url
            }

            It 'User should have two loved tracks' {
                $output.Track | Should -HaveCount 2
            }

            It 'User should not have more than two loved tracks' {
                $output.Track | Should -Not -BeNullOrEmpty
                $output.Track | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMUserLovedTrack: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
