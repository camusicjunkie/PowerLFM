# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMTagTopTag: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTagTopTag'.TagTopTag

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMTagTopTag
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
            $output = Get-LFMTagTopTag
        }

        It 'Should return the correct first top tag name' {
            $output[0].Tag | Should -Be $contextMock.TopTags.Tag[0].Name
        }

        It 'Should return the correct first top tag reach' {
            $output[0].Reach | Should -Be $contextMock.TopTags.Tag[0].Reach
        }

        It 'Should return the correct first top tag count' {
            $output[0].Count | Should -Be $contextMock.TopTags.Tag[0].Count
        }

        It 'Should return the correct second top tag count' {
            $output[1].Count | Should -Be $contextMock.TopTags.Tag[1].Count
        }

        It 'Should return the correct second top tag reach' {
            $output[1].Reach | Should -Be $contextMock.TopTags.Tag[1].Reach
        }

        It 'Tag should have two top tags' {
            $output.Tag | Should -HaveCount 2
        }

        It 'Tag should not have more than two top tags' {
            $output.Tag | Should -Not -BeNullOrEmpty
            $output.Tag | Should -Not -HaveCount 3
        }

        It 'Should call the correct Last.fm get method' {
            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Uri -like "$baseUrl*"
                }
            }
            Should -Invoke @siParams
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Get-LFMTagTopTag } | Should -Throw 'Error'
        }
    }
}
