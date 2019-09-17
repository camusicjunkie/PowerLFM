Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserPersonalTag: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserPersonalTag')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.PersonalTag' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.PersonalTag'
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

        Context 'Parameter [Tag] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Tag

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

        Context 'Parameter [TagType] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq TagType

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

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
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
    $contextMock = $mocks.'Get-LFMUserPersonalTag'.UserPersonalTag

    Describe 'Get-LFMUserPersonalTag: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It 'Should throw when username is null' {
                {Get-LFMUserPersonalTag -UserName $null} | Should -Throw
            }

            It "Should throw when limit has more than 50 values" {
                Set-ItResult -Pending -Because 'the type needs to change on the limit parameter'

                $guptParams = @{
                    UserName = 'UserName'
                    Tag = 'Tag'
                    TagType = 'Artist'
                    Limit = @(1..51)
                }
                {Get-LFMUserPersonalTag @guptParams} | Should -Not -Throw
            }

            It "Should not throw when limit has 1 to 50 values" {
                Set-ItResult -Pending -Because 'the type needs to change on the limit parameter'

                $guptParams = @{
                    UserName = 'UserName'
                    Tag = 'Tag'
                    TagType = 'Album'
                    Limit = @(1..50)
                }
                {Get-LFMUserPersonalTag @guptParams} | Should -Not -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 6
                    guptParams = @{
                        UserName = 'UserName'
                        Tag = 'Tag'
                        TagType = 'Artist'
                    }
                }
                @{
                    times = 7
                    guptParams = @{
                        UserName = 'UserName'
                        Tag = 'Tag'
                        TagType = 'Artist'
                        Limit = '5'
                    }
                }
                @{
                    times = 8
                    guptParams = @{
                        UserName = 'UserName'
                        Tag = 'Tag'
                        TagType = 'Artist'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $guptParams)

                Get-LFMUserPersonalTag @guptParams

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
                $script:output = Get-LFMUserPersonalTag -UserName camusicjunkie -Tag Tag -TagType Artist
            }

            It "User first personal tag artist should have a name of $($contextMock.Taggings.Artists.Artist[0].Name)" {
                $output[0].Artist | Should -Be $contextMock.Taggings.Artists.Artist[0].Name
            }

            It "User first personal tag artist should have an id of $($contextMock.Taggings.Artists.Artist[0].Mbid)" {
                $output[0].Id | Should -Be $contextMock.Taggings.Artists.Artist[0].Mbid
            }

            It "User second personal tag artist should have a url of $($contextMock.Taggings.Artists.Artist[1].Url)" {
                $output[1].Url | Should -Be $contextMock.Taggings.Artists.Artist[1].Url
            }

            It 'User should have two personal tag artists' {
                $output.UserName | Should -HaveCount 2
            }

            It 'User should not have more than two personal tag artists' {
                $output.UserName | Should -Not -BeNullOrEmpty
                $output.UserName | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMUserPersonalTag: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
