BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMUserWeeklyAlbumChart: Interface' -Tag Interface {

    BeforeAll {
        $command = Get-Command -Name 'Get-LFMUserWeeklyAlbumChart'
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.WeeklyAlbumChart' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.WeeklyAlbumChart'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name | Should -Contain '__AllParameterSets'
        }

        BeforeAll {
            $parameterSet = $command.ParameterSets | Where-Object Name -EQ __AllParameterSets
        }

        Context 'Parameter [StartDate] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -EQ StartDate
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.DateTime' {
                $parameter.ParameterType.ToString() | Should -Be System.DateTime
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

            It 'Should have a position of 0' {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [EndDate] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -EQ EndDate
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.DateTime' {
                $parameter.ParameterType.ToString() | Should -Be System.DateTime
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

            It 'Should have a position of 1' {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [UserName] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -EQ UserName
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.String' {
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

            It 'Should have a position of 2' {
                $parameter.Position | Should -Be 2
            }
        }
    }
}

Describe 'Get-LFMUserWeeklyAlbumChart: Unit' -Tag Unit {

    #region Discovery

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserWeeklyAlbumChart'.UserWeeklyAlbumChart

    #endregion Discovery

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserWeeklyAlbumChart'.UserWeeklyAlbumChart

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when username is null' {
            { Get-LFMUserWeeklyAlbumChart -UserName $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserWeeklyAlbumChart
        }

        It 'Should remove common parameters from bound parameters' {
            $siParams = @{
                CommandName     = 'Remove-CommonParameter'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $PSBoundParameters
                }
            }
            Should -Invoke @siParams
        }

        It 'Should convert parameters to format API expects after signing' {
            $siParams = @{
                CommandName = 'ConvertTo-LFMParameter'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Should -Invoke @siParams
        }

        It 'Should take hashtable and build a query for a uri' {
            $siParams = @{
                CommandName = 'New-LFMApiQuery'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Should -Invoke @siParams
        }
    }

    Context 'Output' {

        BeforeAll {
            $output = Get-LFMUserWeeklyAlbumChart
        }

        It "User weekly album chart first album should have name of $($contextMock.WeeklyAlbumChart.Album[0].Name)" {
            $output[0].Album | Should -Be $contextMock.WeeklyAlbumChart.Album[0].Name
        }

        It "User weekly album chart first album should have artist name of $($contextMock.WeeklyAlbumChart.Album[0].Artist.'#Text')" {
            $output[0].Artist | Should -Be $contextMock.WeeklyAlbumChart.Album[0].Artist.'#Text'
        }

        It "User weekly album chart first album should have url of $($contextMock.WeeklyAlbumChart.Album[0].Url)" {
            $output[0].Url | Should -Be $contextMock.WeeklyAlbumChart.Album[0].Url
        }

        It "User weekly album chart second album should have url of $($contextMock.WeeklyAlbumChart.Album[1].Url)" {
            $output[1].Url | Should -Be $contextMock.WeeklyAlbumChart.Album[1].Url
        }

        It "User weekly album chart second album should have artist id with a value of $($contextMock.WeeklyAlbumChart.Album[1].Artist.Mbid)" {
            $output[1].ArtistId | Should -Be $contextMock.WeeklyAlbumChart.Album[1].Artist.Mbid
        }

        It "User weekly album chart second album should have a playcount of $($contextMock.WeeklyAlbumChart.Album[1].PlayCount)" {
            $output[1].PlayCount | Should -Be $contextMock.WeeklyAlbumChart.Album[1].PlayCount
        }

        It 'User weekly album chart should have two albums' {
            $output.Album | Should -HaveCount 2
        }

        It 'User weekly album chart should not have more than two albums' {
            $output.Album | Should -Not -BeNullOrEmpty
            $output.Album | Should -Not -HaveCount 3
        }

        It 'Should call the correct Last.fm get method' {
            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Get-LFMUserWeeklyAlbumChart } | Should -Throw 'Error'
        }
    }
}
