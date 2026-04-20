import Foundation

struct CreateAliasRequestDTO: Encodable {
    let url: String
}

public struct CreateAliasResponseDTO: Decodable {
    let alias: String
    let links: LinksDTO
    
    enum CodingKeys: String, CodingKey {
        case alias
        case links = "_links"
    }
}

struct LinksDTO: Decodable {
    let selfLink: String
    let compact: String
    
    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case compact = "short"
    }
}

extension CreateAliasResponseDTO {
    func toDomain() -> URLAlias {
        URLAlias(
            originalURL: links.selfLink,
            alias: alias,
            selfLink: links.selfLink,
            compactLink: links.compact
        )
    }
}
