$here = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$module = (Get-Command -Name ($sut -replace '.ps1')).ModuleName
. "$here\$module\Public\$sut"

Describe "Add-LFMArtistTag" {
    It "does something useful" {
        $true | Should -Be $false
    }
}
