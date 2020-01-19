Deploy PowerLFM {
    By PSGalleryModule {
        FromSource (Split-Path -Path $env:BHBuildModulePath)
        To Local
        Tagged Local
        WithOptions @{
            ApiKey = $NuGetApiKey
        }
    }
}
