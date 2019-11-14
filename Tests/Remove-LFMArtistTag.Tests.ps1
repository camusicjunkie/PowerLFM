Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Remove-LFMArtistTag: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Remove-LFMArtistTag')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

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

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }
    }
}

InModuleScope PowerLFM {

    Describe 'Remove-LFMArtistTag: Unit' -Tag Unit {

        Mock Remove-CommonParameter {
            [hashtable] @{
                Artist = 'Artist'
                Tag = 'Tag'
            }
        }
        Mock ConvertTo-LFMParameter
        Mock Get-LFMSignature
        Mock New-LFMApiQuery
        Mock Invoke-LFMApiUri
        Mock Get-LFMIgnoredMessage { @{ Code = 0 } }

        Context 'Input' {

            It 'Should throw when Album is null' {
                {Remove-LFMArtistTag -Album $null} | Should -Throw
            }

            It 'Should throw when Tag has more than 1 value' {
                $aatParams = @{
                    Artist = 'Artist'
                    Tag = @(1..2)
                }
                {Remove-LFMArtistTag @aatParams} | Should -Throw
            }
        }

        Context 'Execution' {

            Remove-LFMArtistTag -Artist Artist -Tag Tag -Confirm:$false

            It "Should remove common parameters from bound parameters" {
                $amParams = @{
                    CommandName     = 'Remove-CommonParameter'
                    Exactly         = $true
                    Times           = 1
                    ParameterFilter = {
                        $PSBoundParameters
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should create a signature from the parameters passed in' {
                $amParams = @{
                    CommandName     = 'Get-LFMSignature'
                    Exactly         = $true
                    Times           = 1
                    ParameterFilter = {
                        $Artist -eq 'Artist' -and
                        $Tag -eq 'Tag' -and
                        $Method -eq 'artist.removeTag'
                    }
                }
                Assert-MockCalled @amParams
            }

            It "Should convert parameters to format API expects after signing" {
                $amParams = @{
                    CommandName = 'ConvertTo-LFMParameter'
                    Exactly     = $true
                    Times       = 1
                }
                Assert-MockCalled @amParams
            }

            It "Should take hashtable and build a query for a uri" {
                $amParams = @{
                    CommandName = 'New-LFMApiQuery'
                    Exactly     = $true
                    Times       = 1
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            It 'Should call the Last.fm Rest API for artist.removeTag post method' {
                Remove-LFMArtistTag -Artist Artist -Tag Tag -Confirm:$false

                $amParams = @{
                    CommandName = 'Invoke-LFMApiUri'
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                    ParameterFilter = {
                        $Method -eq 'Post' -and
                        $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                    }
                }
                Assert-MockCalled @amParams
            }

            It 'Should send proper output when -Whatif is used' {
                $output = Remove-LFMArtistTag -Artist Artist -Tag Tag -Confirm:$false -Verbose 4>&1
                $output | Should -Match 'Performing the operation "Removing artist tag: Tag" on target "Artist: Artist".'
            }

            It "Should throw when an error is returned in the response" {
                Mock Invoke-LFMApiUri { throw 'Error' }

                { Remove-LFMAlbumTag -Album Album -Artist Artist -Tag Tag -Confirm:$false } | Should -Throw 'Error'
            }
        }
    }
}

Describe 'Remove-LFMArtistTag: Integration' -Tag Integration {

    BeforeAll {
        Get-LFMConfiguration

        $atParams = @{
            Artist = 'Deftones'
            Tag = 'randomValue'
            Confirm = $false
        }
        Add-LFMArtistTag @atParams
    }

    Context "Rest API calls" {

        It "Should contain the random value tag before removing it" {
            $tag = Get-LFMArtistTag -Artist Deftones
            $tag.Tag | Should -Contain 'randomValue'
        }

        It "Should remove the new random value tag from the artist" {
            Remove-LFMArtistTag @atParams
            $tag = Get-LFMArtistTag -Artist Deftones
            @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -BeNullOrEmpty
            @($tag).Where({$_.Tag -eq 'randomValue'}).Tag | Should -Not -Be 'randomValue'
        }
    }
}
