import Foundation

struct URLAlias: Hashable, Identifiable {
    let id: String
    let originalURL: String
    let alias: String
    let selfLink: String
    let compactLink: String
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        originalURL: String,
        alias: String,
        selfLink: String,
        compactLink: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.originalURL = originalURL
        self.alias = alias
        self.selfLink = selfLink
        self.compactLink = compactLink
        self.createdAt = createdAt
    }
}
