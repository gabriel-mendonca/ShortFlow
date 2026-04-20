import Foundation

protocol URLRepositoryProtocol {
    func createAlias(for url: String) async throws -> URLAlias
}
