extension URLAlias {
    static func fixture(
        id: String = "1",
        originalURL: String = "https://short.link/",
        alias: String = "abc123"
    ) -> URLAlias {
        URLAlias(
            id: id,
            originalURL: originalURL,
            alias: alias,
            selfLink: originalURL,
            compactLink: "https://short.link/\(alias)"
        )
    }
}
