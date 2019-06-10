Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Add-LFMArtistTag: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command 'Add-LFMArtistTag')
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object { $_.'Name' -eq '__AllParameterSets' }

        Context 'Parameter [Artist] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object { $_.'Name' -eq 'Artist' }

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

            $parameter = $parameterSet.Parameters | Where-Object { $_.'Name' -eq 'Tag' }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String[]" {
                $parameter.ParameterType.ToString() | Should -Be System.String[]
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
    }
}

InModuleScope PowerLFM {
    Describe 'Add-LFMArtistTag: Unit' -Tag Unit {
        Mock Get-LFMArtistSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

        Context 'Input' {
            It 'Should throw when Artist is null' {
                {Add-LFMArtistTag -Artist $null} | Should -Throw
            }

            It 'Should throw when Tag has more than 10 values' {
                $aatParams = @{
                    Artist = 'Artist'
                    Tag = @(1..11)
                }
                {Add-LFMArtistTag @aatParams} | Should -Throw
            }

            It 'Should not throw when Tag has 1 to 10 values' {
                $aatParams = @{
                    Artist = 'Artist'
                    Tag = @(1..10)
                }
                {Add-LFMArtistTag @aatParams} | Should -Not -Throw
            }
        }

        Context 'Execution' {
            Mock ForEach-Object

            $aatParams = @{
                Artist = 'Artist'
                Tag = 'Tag'
            }
            Add-LFMArtistTag @aatParams

            It 'Should create a signature from the parameters passed in' {
                $amParams = @{
                    CommandName = 'Get-LFMArtistSignature'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Artist -eq 'Artist' -and
                        $Tag -eq 'Tag' -and
                        $Method -eq 'artist.addTags'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should loop through each parameter in url string' {
                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = 6
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {
            $aatParams = @{
                Artist = 'Artist'
                Tag = 'Tag'
            }

            It 'Should call the Last.fm Rest API for artist.addTags post method' {
                Add-LFMArtistTag @aatParams

                $amParams = @{
                    CommandName = 'Invoke-WebRequest'
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                    ParameterFilter = {
                        $Method -eq 'Post'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should send proper output when -Whatif is used' {
                $output = Add-LFMArtistTag @aatParams -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Adding artist tag: Tag" on target "Artist: Artist".'
            }

            It 'Should send verbose output when -Verbose is used' {
                Add-LFMArtistTag @aatParams -Verbose 4>&1

                $amParams = @{
                    CommandName = 'Write-Verbose'
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @amParams
            }
        }
    }
}

Describe 'Add-LFMArtistTag: Integration' -Tag Integration {

    BeforeAll {
        Get-LFMConfiguration

        $atParams = @{
            Artist = 'Deftones'
            Tag = 'randomValue'
            Confirm = $false
        }
        Remove-LFMArtistTag @atParams
    }

    It "Should not contain the random value tag before adding it" {
        $tag = Get-LFMArtistTag -Artist Deftones
        $tag.Tag | Should -Not -Be 'randomValue'
    }

    It "Should add the new random value tag to the artist" {
        Add-LFMArtistTag @atParams
        $tag = Get-LFMArtistTag -Artist Deftones
        @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -Not -BeNullOrEmpty
        @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -Be 'randomValue'
    }

    AfterAll {
        Remove-LFMArtistTag @atParams
    }
}
