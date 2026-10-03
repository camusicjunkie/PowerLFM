Describe 'Commands describe a Method: Unit' -Tag Unit {

    BeforeDiscovery {
        # Internal seams of Invoke-LFMApiMethod. A command that calls one is building its own
        # request again, which is the recipe ADR-0008 retired.
        $seams = 'ConvertTo-LFMParameter', 'Get-LFMSignature', 'New-LFMApiQuery', 'Invoke-LFMApiUri'

        $publicPath = "$PSScriptRoot/../../Public"
        $commands = foreach ($file in Get-ChildItem -Path $publicPath -Filter '*.ps1') {
            @{ Name = $file.BaseName; Path = $file.FullName; Seams = $seams }
        }

        # With no files there would be no tests, and the guard would pass having checked nothing.
        if (-not $commands) { throw "No commands found under $publicPath." }
    }

    It '<Name> calls none of the request seams' -ForEach $commands {
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $null, [ref] $errors)

        # A file that does not parse yields a partial tree, which could hide a call.
        $errors | Should -BeNullOrEmpty

        $called = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true) |
            ForEach-Object { $_.GetCommandName() }

        $called | Where-Object { $_ -in $Seams } | Should -BeNullOrEmpty
    }
}
