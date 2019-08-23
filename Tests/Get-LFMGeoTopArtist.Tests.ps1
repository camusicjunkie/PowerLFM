Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMGeoTopArtist: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMGeoTopArtist')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Geo.TopArtists' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Geo.TopArtists'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [Country] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Country

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
                $parameter.IsMandatory | Should -BeTrue
            }

            It 'ValueFromPipeline should be set to True' {
                $parameter.ValueFromPipeline | Should -BeTrue
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
    $contextMock = $mocks.'Get-LFMGeoTopArtist'.GeoTopArtist

    Describe 'Get-LFMGeoTopArtist: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when limit is greater than 119" {
                {Get-LFMGeoTopArtist -Country Country -Limit 120} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    ggtaParams = @{
                        Country = 'Country'
                    }
                }
                @{
                    times = 5
                    ggtaParams = @{
                        Country = 'Country'
                        Limit = '5'
                    }
                }
                @{
                    times = 6
                    ggtaParams = @{
                        Country = 'Country'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $ggtaParams)

                Get-LFMGeoTopArtist @ggtaParams

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
                $script:output = Get-LFMGeoTopArtist -Country 'Country'
            }

            It "Country first top artist should have name of $($contextMock.topartists.artist[0].name)" {
                $output.Artist[0] | Should -Be $contextMock.topartists.artist[0].name
            }

            It "Country first top artist should have id of $($contextMock.topartists.artist[0].mbid)" {
                $output.Id[0] | Should -Be $contextMock.topartists.artist[0].mbid
            }

            It "Country first top artist should have listeners with a value of $($contextMock.topartists.artist[0].Listeners)" {
                $output.Listeners[0] | Should -BeOfType [int]
                $output.Listeners[0] | Should -Be $contextMock.topartists.artist[0].Listeners
            }

            It "Country second top artist should have listeners with a value of $($contextMock.topartists.artist[1].Listeners)" {
                $output.Listeners[1] | Should -BeOfType [int]
                $output.Listeners[1] | Should -Be $contextMock.topartists.artist[1].Listeners
            }

            It "Country second top artist should have track url of $($contextMock.topartists.artist[1].url)" {
                $output.Url[1] | Should -Be $contextMock.topartists.artist[1].url
            }

            It 'Country should have two top artists' {
                $output.Artist | Should -HaveCount 2
            }

            It 'Country should not have more than two top artists' {
                $output.Artist | Should -Not -BeNullOrEmpty
                $output.Artist | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMGeoTopArtist: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
