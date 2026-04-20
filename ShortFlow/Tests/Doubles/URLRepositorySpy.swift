// MARK: - Spy

@testable import ShortFlow

final class URLRepositorySpy: URLRepositoryProtocol {

    private(set) var receivedURLs: [String] = []
    var result: Result<URLAlias, Error> = .failure(NetworkError.unknown)

    func createAlias(for url: String) async throws -> URLAlias {
        receivedURLs.append(url)
        return try result.get()
    }
}
