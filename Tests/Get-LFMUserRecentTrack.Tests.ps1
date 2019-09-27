Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserRecentTrack: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserRecentTrack')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.RecentTrack' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.RecentTrack'
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

        Context 'Parameter [StartDate] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq StartDate

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

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [EndDate] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq EndDate

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

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }

        Context 'Parameter [Extended] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Extended

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

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of -2147483648" {
                $parameter.Position | Should -Be -2147483648
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

            It "Should have a position of 3" {
                $parameter.Position | Should -Be 3
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

            It "Should have a position of 4" {
                $parameter.Position | Should -Be 4
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserRecentTrack'.UserRecentTrack

    Describe 'Get-LFMUserRecentTrack: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when username is null" {
                {Get-LFMUserRecentTrack -UserName $null} | Should -Throw
            }

            It "Should throw when limit has more than 50 values" {
                Set-ItResult -Pending -Because 'the type needs to change on the limit parameter'

                $gurtParams = @{
                    UserName = 'UserName'
                    Limit = @(1..51)
                }
                {Get-LFMUserRecentTrack @gurtParams} | Should -Throw
            }

            It "Should not throw when limit has 1 to 50 values" {
                Set-ItResult -Pending -Because 'the type needs to change on the limit parameter'

                $gurtParams = @{
                    UserName = 'UserName'
                    Limit = @(1..50)
                }
                {Get-LFMUserRecentTrack @gurtParams} | Should -Not -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    gurtParams = @{
                        UserName = 'UserName'
                    }
                }
                @{
                    times = 5
                    gurtParams = @{
                        UserName = 'UserName'
                        StartDate = '1 Jan 1970'
                    }
                }
                @{
                    times = 6
                    gurtParams = @{
                        UserName = 'UserName'
                        StartDate = '1 Jan 1970'
                        EndDate = '2 Jan 1970'
                    }
                }
                @{
                    times = 7
                    gurtParams = @{
                        UserName = 'UserName'
                        StartDate = '1 Jan 1970'
                        EndDate = '2 Jan 1970'
                        Limit = '5'
                    }
                }
                @{
                    times = 8
                    gurtParams = @{
                        UserName = 'UserName'
                        StartDate = '1 Jan 1970'
                        EndDate = '2 Jan 1970'
                        Limit = '5'
                        Page = '1'
                    }
                }
                @{
                    times = 9
                    gurtParams = @{
                        UserName = 'UserName'
                        StartDate = '1 Jan 1970'
                        EndDate = '2 Jan 1970'
                        Limit = '5'
                        Page = '1'
                        Extended = $true
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $gurtParams)

                Get-LFMUserRecentTrack @gurtParams

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

            $output = Get-LFMUserRecentTrack -UserName camusicjunkie

            It "User first recent track should be playing now" {
                $output[0].NowPlaying | Should -BeTrue
            }

            It "User first recent track should have a name of $($contextMock.RecentTracks.Track[0].Name)" {
                $output[0].Track | Should -Be $contextMock.RecentTracks.Track[0].Name
            }

            It "User first recent track should have an artist name of $($contextMock.RecentTracks.Track[0].Artist.'#Text')" {
                $output[0].Artist | Should -Be $contextMock.RecentTracks.Track[0].Artist.'#Text'
            }

            $output = Get-LFMUserRecentTrack -UserName camusicjunkie -Extended

            It "User second recent track should have an album name of $($contextMock.RecentTracks.Track[1].Album.'#Text')" {
                $output[1].Album | Should -Be $contextMock.RecentTracks.Track[1].Album.'#Text'
            }

            It "User second recent track should have scrobble time of $($mocks.UnixTime.From)" {
                $output[1].ScrobbleTime | Should -Be $mocks.UnixTime.From
            }

            It "User extended second recent track should be loved" {
                $output[1].Loved | Should -Be 'Yes'
            }

            It "User extended third recent track should have an artist name of $($contextMock.RecentTracks.Track[2].Artist.Name)" {
                $output[2].Artist | Should -Be $contextMock.RecentTracks.Track[2].Artist.Name
            }
        }
    }
}

Describe 'Get-LFMUserRecentTrack: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
