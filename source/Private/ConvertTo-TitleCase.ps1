function ConvertTo-TitleCase {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]] $String
    )

    process {
        foreach ($s in $String) {
            (Get-Culture).TextInfo.ToTitleCase($s)
        }
    }
}
