
@testable import ShortFlow

final class MockCreateAliasUseCase: CreateAliasUseCaseProtocol {

    var executeResult: Result<URLAlias, Error> = .failure(NetworkError.unknown)
    private(set) var executeCalls: [String] = []

    func execute(url: String) async throws -> URLAlias {
        executeCalls.append(url)
        return try executeResult.get()
    }
}
