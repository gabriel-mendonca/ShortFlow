import Foundation

final class URLRepository: URLRepositoryProtocol {
    
    private let networkClient: NetworkClientProtocol
    
    // MARK: - Initialization
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    func createAlias(for url: String) async throws -> URLAlias {
        let request = CreateAliasRequest(url: url)
        let response = try await networkClient.execute(request)
        return response.toDomain()
    }
}
