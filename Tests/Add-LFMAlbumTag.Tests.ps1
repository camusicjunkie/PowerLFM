Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

InModuleScope PowerLFM {
    Describe 'Add-LFMAlbumTag: Unit' -Tag Unit {
        Mock New-LFMAlbumSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

        Context 'Parameter attribute validation' {
            $command = Get-Command -Name Add-LFMAlbumTag

            $testCases = @(
                @{Name = 'Album'}
                @{Name = 'Artist'}
                @{Name = 'Tag'}
            )

            It 'Should have cmdletbinding declared' {
                $command.CmdletBinding | Should -BeTrue
            }

            It '<Name> parameter should be mandatory' -TestCases $testCases {
                param ($Name)
                $command.Parameters[$Name].Attributes.Mandatory | Should -BeTrue
            }

            It '<Name> parameter should accept value from pipeline by property name' -TestCases $testCases {
                param ($Name)
                $command.Parameters[$Name].Attributes.ValueFromPipelineByPropertyName | Should -BeTrue
            }
        }

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
                    CommandName = 'New-LFMAlbumSignature'
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

            It 'Should call the Last.fm Rest API for album.addTags method' {
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
                $output | Should -Match '^Performing the operation "Adding album tag: Tag" on target "Album: Album".$'
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

InModuleScope PowerLFM {
    Describe 'Add-LFMAlbumTag: Integration' -Tag Integration {

        BeforeAll {
            Get-LFMConfiguration

            $atParams = @{
                Album = 'Gore'
                Artist = 'Deftones'
                Tag = 'Rock'
                Confirm = $false
            }
            Remove-LFMAlbumTag @atParams
        }

        It "Should not contain the rock tag before adding it" {
            $tag = Get-LFMAlbumTag -Album Gore -Artist Deftones
            $tag.Tag | Should -Not -Be 'Rock'
        }

        It "Should add the new rock tag to the album" {
            Add-LFMAlbumTag @atParams
            $tag = Get-LFMAlbumTag -Album Gore -Artist Deftones
            $tag.Where({$_.Tag -eq 'Rock'}).Tag | Should -Be 'Rock'
            $tag.Where({$_.Tag -eq 'Rock'}).Tag | Should -Not -BeNullOrEmpty
        }

        AfterAll {
            Remove-LFMAlbumTag @atParams
        }
    }
}
