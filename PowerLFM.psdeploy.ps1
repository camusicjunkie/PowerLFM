Deploy PowerLFM {
    By PSGalleryModule {
        FromSource PowerLFM
        To Local
        Tagged Local
        WithOptions @{
            ApiKey = $env:NuGetApiKey
        }
    }
}
