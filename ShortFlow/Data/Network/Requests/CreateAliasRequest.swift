import Foundation

struct CreateAliasRequest: NetworkRequest {
    typealias Response = CreateAliasResponseDTO
    
    let path: String = "/api/alias"
    let method: HTTPMethod = .post
    let body: Encodable?
    
    init(url: String) {
        self.body = CreateAliasRequestDTO(url: url)
    }
}
