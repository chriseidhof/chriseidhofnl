import StaticSite

extension EnvironmentValues {
    public var relativeOutputPath: String {
        let prefix = siteOutputPath.path
        let urlString = output.path
        assert(urlString.hasPrefix(prefix))
        return String(urlString.dropFirst(prefix.count))
    }
}

