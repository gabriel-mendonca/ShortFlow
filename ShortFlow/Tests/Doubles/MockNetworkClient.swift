import Foundation
@testable import ShortFlow

final class MockNetworkClient: NetworkClientProtocol {

    var executeCalls: [Any] = []
    var executeResult: Result<Any, Error> = .failure(NetworkError.unknown)

    func execute<T: NetworkRequest>(_ request: T) async throws -> T.Response {
        executeCalls.append(request)
        switch executeResult {
        case .success(let value):
            guard let typed = value as? T.Response else {
                throw NetworkError.unknown
            }
            return typed
        case .failure(let error):
            throw error
        }
    }
}
