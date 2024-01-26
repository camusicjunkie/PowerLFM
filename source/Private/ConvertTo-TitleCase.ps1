function ConvertTo-TitleCase {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]] $String
    )

    process {
        (Get-Culture).TextInfo.ToTitleCase($String)
    }
}
