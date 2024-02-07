function Show-LFMAuthWindow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [uri] $Url
    )

    Add-Type -AssemblyName System.Windows.Forms

    $form = New-Object -TypeName System.Windows.Forms.Form -Property @{
        Width = 516
        Height = 638
        StartPosition = 1
        FormBorderStyle = 'Fixed3D'
        MinimizeBox = $false
        MaximizeBox = $false
        ShowIcon = $false
    }

    $web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{
        Width = 500
        Height = 600
        ScrollBarsEnabled = $false
        Url = $Url
    }

    $docComp = {
        $uri = $web.Url.AbsoluteUri
        if ($uri -cmatch '/None') {
            $form.Close()
        }
    }

    $web.ScriptErrorsSuppressed = $true
    $web.Add_DocumentCompleted($docComp)

    $form.Controls.Add($web)
    $form.Activate()
    $null = $form.ShowDialog()
}
