Describe 'Messages are localized: Unit' -Tag Unit {

    BeforeDiscovery {
        $sourcePath = "$PSScriptRoot/../.."
        $files = foreach ($file in Get-ChildItem -Path "$sourcePath/Public", "$sourcePath/Private" -Filter '*.ps1') {
            @{ Name = $file.BaseName; Path = $file.FullName }
        }

        # With no files there would be no tests, and the guard would pass having checked nothing.
        if (-not $files) { throw "No functions found under $sourcePath." }
    }

    It '<Name> takes every thrown, warned and error message from localizedData' -ForEach $files {
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $null, [ref] $errors)

        # A file that does not parse yields a partial tree, which could hide a message.
        $errors | Should -BeNullOrEmpty

        $isLiteral = {
            param ($node)
            ($node -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
                $node.StringConstantType -ne 'BareWord') -or
            $node -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
        }

        $messages = @(
            # throw 'text'
            foreach ($throw in $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.ThrowStatementAst] }, $true)) {
                # A bare throw rethrows and has no pipeline
                if ($throw.Pipeline) { $throw.Pipeline.PipelineElements[0].Expression }

                # throw [SomeException]::new('text'). Only the first argument is a message:
                # the later ones of an ErrorRecord are its id and category, not text for a user.
                $throw.FindAll({ $args[0] -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                        $args[0].Static -and $args[0].Member.Value -eq 'new' }, $true) |
                    ForEach-Object { @($_.Arguments)[0] }
            }

            # Write-Warning 'text', Write-Error -Message 'text'
            foreach ($write in $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                        $args[0].GetCommandName() -in 'Write-Warning', 'Write-Error' }, $true)) {
                $write.CommandElements[1]
                $write.CommandElements | Where-Object { $_.ParameterName -eq 'Message' } |
                    ForEach-Object { $write.CommandElements[$write.CommandElements.IndexOf($_) + 1] }
            }
        )

        $messages | Where-Object { $_ -and (& $isLiteral $_) } |
            ForEach-Object { "line $($_.Extent.StartLineNumber): $($_.Extent.Text)" } |
            Should -BeNullOrEmpty
    }
}
