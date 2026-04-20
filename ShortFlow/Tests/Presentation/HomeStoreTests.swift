import XCTest
@testable import ShortFlow

@MainActor
final class HomeStoreTests: XCTestCase {

    // MARK: - Initial State

    func test_initialState_withEmptyCache() {
        let (_, sut, _) = makeSUT()

        XCTAssertEqual(sut.state.urlInput, "")
        XCTAssertTrue(sut.state.aliases.isEmpty)
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNil(sut.state.errorMessage)
    }

    func test_initialState_loadsAliasesFromCache() {
        let alias = URLAlias.fixture(id: "cached")
        let (cache, sut, _) = makeSUT()

        XCTAssertEqual(sut.state.aliases, [alias])
        XCTAssertEqual(cache.storedAliases, [alias])
    }

    // MARK: - Reducer

    func test_dispatch_updateURLInput_updatesStateOnly() {
        let (_, sut, useCase) = makeSUT()

        sut.dispatch(.updateURLInput("https://example.com"))

        XCTAssertEqual(sut.state.urlInput, "https://example.com")
        XCTAssertTrue(useCase.executeCalls.isEmpty)
    }

    func test_dispatch_clearError_setsErrorToNil() {
        let (_, sut, _) = makeSUT()

        sut.dispatch(.createAliasFailure("Error"))
        sut.dispatch(.clearError)

        XCTAssertNil(sut.state.errorMessage)
    }

    // MARK: - Effect Success

    func test_createAlias_success_updatesState() async {
        let alias = URLAlias.fixture(id: "new")
        let (cache, sut, useCase) = makeSUT()

        useCase.executeResult = .success(alias)

        sut.dispatch(.updateURLInput("https://example.com"))
        sut.dispatch(.createAliasRequest)

        await awaitState(sut) { !$0.isLoading }

        XCTAssertEqual(sut.state.aliases, [alias])
        XCTAssertEqual(sut.state.urlInput, "")
        XCTAssertNil(sut.state.errorMessage)
        XCTAssertEqual(useCase.executeCalls, ["https://example.com"])
        XCTAssertEqual(cache.addCalls, [alias])
    }

    // MARK: - Effect Failure

    func test_createAlias_failure_updatesErrorState() async {
        let (cache, sut, useCase) = makeSUT()

        useCase.executeResult = .failure(NetworkError.unknown)

        sut.dispatch(.updateURLInput("https://example.com"))
        sut.dispatch(.createAliasRequest)

        await awaitState(sut) { !$0.isLoading }

        XCTAssertNotNil(sut.state.errorMessage)
        XCTAssertTrue(sut.state.aliases.isEmpty)
        XCTAssertTrue(cache.addCalls.isEmpty)
    }

    // MARK: - Delete

    func test_deleteAlias_removesFromStateAndCache() {
        let alias = URLAlias.fixture(id: "delete")
        let (cache, sut, _) = makeSUT(cache: MockMemoryStore())

        sut.dispatch(.deleteAliasSuccess("delete"))

        XCTAssertTrue(sut.state.aliases.isEmpty)
        XCTAssertEqual(cache.removeCalls, [alias.id])
    }

    // MARK: - Factory

    
    private func makeSUT(
        cache: MockMemoryStore = MockMemoryStore(),
        useCase: MockCreateAliasUseCase = MockCreateAliasUseCase()
    ) -> (
        cache: MockMemoryStore,
        sut: HomeStore,
        useCase: MockCreateAliasUseCase
    ) {
        let sut = HomeStore(
            initialState: .initial,
            cache: cache,
            createAliasUseCase: useCase
        )

        return (cache, sut, useCase)
    }
}

