properties {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
    $scriptPath = "$PSScriptRoot\"
}

task default -depends Analyze, Test

task Analyze {
    $saResults = Invoke-ScriptAnalyzer -Path $scriptPath -Severity @('Error', 'Warning') -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table
        Write-Error -Message 'One or more Script Analyzer errors/warnings were found. Build cannot continue!'
    }
}

task Test {
    $testResultsFile = ".\TestsResults.xml"
    $appveyorPath = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
    $testResults = Invoke-Pester -Path $PSScriptRoot -OutputFile $testResultsFile -OutputFormat NUnitXml -PassThru
    (New-Object 'System.Net.WebClient').UploadFile($appveyorPath, (Resolve-Path $testResultsFile))

    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}

task Deploy -depends Analyze, Test {
    Invoke-PSDeploy -Path '.\ServerInfo.psdeploy.ps1' -Force -Verbose:$VerbosePreference
}
