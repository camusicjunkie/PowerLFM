Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

InModuleScope PowerLFM {
    Describe 'Add-LFMArtistTag: Unit' -Tag Unit {
        Mock Get-LFMArtistSignature
        Mock Invoke-WebRequest
        Mock Write-Verbose

        Context 'Parameter attribute validation' {
            $command = Get-Command -Name Add-LFMArtistTag

            $testCases = @(
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
        if ($env:APPVEYOR) {
            $script:LFMConfig = [pscustomobject] @{
                'APIKey' = $env:LFMApiKey
                'SessionKey' = $env:LFMSessionKey
            }
            Write-Output [$LFMConfig.ApiKey]
        }
        else {
            Get-LFMConfiguration
        }

        $atParams = @{
            Artist = 'Deftones'
            Tag = 'Rock'
            Confirm = $false
        }
        Remove-LFMArtistTag @atParams
    }

    It "Should not contain the rock tag before adding it" {
        $tag = Get-LFMArtistTag -Artist Deftones
        $tag.Tag | Should -Not -Be 'Rock'
    }

    It "Should add the new rock tag to the artist" {
        Add-LFMArtistTag @atParams
        $tag = Get-LFMArtistTag -Artist Deftones
        $tag.Where({$_.Tag -eq 'Rock'}).Tag | Should -Not -BeNullOrEmpty
        $tag.Where({$_.Tag -eq 'Rock'}).Tag | Should -Be 'Rock'
    }

    AfterAll {
        Remove-LFMArtistTag @atParams
    }
}
