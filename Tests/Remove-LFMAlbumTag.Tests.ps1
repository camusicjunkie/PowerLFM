Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Remove-LFMAlbumTag: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Remove-LFMAlbumTag')
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

            It 'ValueFromRemainingArguments should be set to False' {
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

    Describe 'Remove-LFMAlbumTag: Unit' -Tag Unit {

        Mock Get-LFMAlbumSignature
        Mock Invoke-RestMethod
        Mock Write-Verbose

        Context 'Input' {

            It 'Should throw when Album is null' {
                {Remove-LFMAlbumTag -Album $null} | Should -Throw
            }

            It 'Should throw when Tag has more than 1 value' {
                $aatParams = @{
                    Album = 'Album'
                    Artist = 'Artist'
                    Tag = @(1..2)
                }
                {Remove-LFMAlbumTag @aatParams} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock ForEach-Object

            $aatParams = @{
                Album = 'Album'
                Artist = 'Artist'
                Tag = 'Tag'
                Confirm = $false
            }
            Remove-LFMAlbumTag @aatParams

            It 'Should create a signature from the parameters passed in' {
                $amParams = @{
                    CommandName = 'Get-LFMAlbumSignature'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Album -eq 'Album' -and
                        $Artist -eq 'Artist' -and
                        $Tag -eq 'Tag' -and
                        $Method -eq 'album.removeTag'
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
                Confirm = $false
            }

            It 'Should call the Last.fm Rest API for album.removeTag post method' {
                Remove-LFMAlbumTag @aatParams

                $amParams = @{
                    CommandName = 'Invoke-RestMethod'
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
                $output = Remove-LFMAlbumTag @aatParams -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Removing album tag: Tag" on target "Album: Album".'
            }

            It 'Should send verbose output when -Verbose is used' {
                Mock Invoke-RestMethod {$mocks}

                Remove-LFMAlbumTag @aatParams -Verbose 4>&1

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

Describe 'Remove-LFMAlbumTag: Integration' -Tag Integration {

    BeforeAll {
        Get-LFMConfiguration

        $atParams = @{
            Album = 'Gore'
            Artist = 'Deftones'
            Tag = 'randomValue'
            Confirm = $false
        }
        Add-LFMAlbumTag @atParams
    }

    Context "Rest API calls" {

        It "Should contain the random value tag before removing it" {
            $tag = Get-LFMAlbumTag -Album Gore -Artist Deftones
            $tag.Tag | Should -Contain 'randomValue'
        }

        It "Should remove the new random value tag from the album" {
            Remove-LFMAlbumTag @atParams
            $tag = Get-LFMAlbumTag -Album Gore -Artist Deftones
            @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -BeNullOrEmpty
            @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -Not -Be 'randomValue'
        }
    }
}
