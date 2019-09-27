Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Add-LFMAlbumTag: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Add-LFMAlbumTag')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [Album] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Album

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

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [Tag] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Tag

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

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }
    }
}

InModuleScope PowerLFM {

    Describe 'Add-LFMAlbumTag: Unit' -Tag Unit {

        Mock Get-LFMAlbumSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

        Context 'Input' {

            It 'Should throw when Album is null' {
                {Add-LFMAlbumTag -Album $null} | Should -Throw
            }

            It 'Should throw when Tag has more than 10 values' {
                $aatParams = @{
                    Album = 'Album'
                    Artist = 'Artist'
                    Tag = @(1..11)
                }
                {Add-LFMAlbumTag @aatParams} | Should -Throw
            }

            It 'Should not throw when Tag has 1 to 10 values' {
                $aatParams = @{
                    Album = 'Album'
                    Artist = 'Artist'
                    Tag = @(1..10)
                }
                {Add-LFMAlbumTag @aatParams} | Should -Not -Throw
            }
        }

        Context 'Execution' {

            Mock ForEach-Object

            $aatParams = @{
                Album = 'Album'
                Artist = 'Artist'
                Tag = 'Tag'
            }
            Add-LFMAlbumTag @aatParams

            It 'Should create a signature from the parameters passed in' {
                $amParams = @{
                    CommandName = 'Get-LFMAlbumSignature'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Album -eq 'Album' -and
                        $Artist -eq 'Artist' -and
                        $Tag -eq 'Tag' -and
                        $Method -eq 'album.addTags'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should loop through each parameter in url string' {
                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = 7
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            $aatParams = @{
                Album = 'Album'
                Artist = 'Artist'
                Tag = 'Tag'
            }

            It 'Should call the Last.fm Rest API for album.addTags post method' {
                Add-LFMAlbumTag @aatParams

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
                $output = Add-LFMAlbumTag @aatParams -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Adding album tag: Tag" on target "Album: Album".'
            }

            It 'Should send verbose output when -Verbose is used' {
                Add-LFMAlbumTag @aatParams -Verbose 4>&1

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

Describe 'Add-LFMAlbumTag: Integration' -Tag Integration {

    BeforeAll {
        Get-LFMConfiguration

        $atParams = @{
            Album = 'Gore'
            Artist = 'Deftones'
            Tag = 'randomValue'
            Confirm = $false
        }
        Remove-LFMAlbumTag @atParams
    }

    Context "Rest API calls" {

        It "Should not contain the random value tag before adding it" {
            $tag = Get-LFMAlbumTag -Album Gore -Artist Deftones
            $tag.Tag | Should -Not -Be 'randomValue'
        }

        It "Should add the new random value tag to the album" {
            Add-LFMAlbumTag @atParams
            $tag = Get-LFMAlbumTag -Album Gore -Artist Deftones
            @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -Not -BeNullOrEmpty
            @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -Be 'randomValue'
        }
    }

    AfterAll {
        Remove-LFMAlbumTag @atParams
    }
}
