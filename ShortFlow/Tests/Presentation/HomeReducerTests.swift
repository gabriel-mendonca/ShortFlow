import XCTest
@testable import ShortFlow

final class HomeReducerTests: XCTestCase {

    // MARK: - Estado inicial

    func testInitialState_isExpected() {
        let state = HomeState.initial
        XCTAssertEqual(state.urlInput, "")
        XCTAssertTrue(state.aliases.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.errorMessage)
    }

    func testReduce_preservesOtherStateWhenUpdatingInput() {
        var state = HomeState.initial
        state.aliases = [URLAlias.fixture(id: "1")]
        state.isLoading = true

        let newState = HomeReducer.reduce(state, .updateURLInput("https://new.com"))

        XCTAssertEqual(newState.urlInput, "https://new.com")
        XCTAssertNil(newState.errorMessage)
        XCTAssertEqual(newState.aliases.count, 1)
        XCTAssertTrue(newState.isLoading)
    }

    // MARK: - updateURLInput

    func testUpdateURLInput_updatesInputAndClearsError() {
        var state = HomeState.initial
        state.errorMessage = "Erro anterior"

        let newState = HomeReducer.reduce(state, .updateURLInput("https://example.com"))

        XCTAssertEqual(newState.urlInput, "https://example.com")
        XCTAssertNil(newState.errorMessage)
    }

    func testUpdateURLInput_idempotentWhenSameValue() {
        var state = HomeState.initial
        state.urlInput = "https://example.com"

        let newState = HomeReducer.reduce(state, .updateURLInput("https://example.com"))

        XCTAssertEqual(newState.urlInput, "https://example.com")
    }

    // MARK: - createAliasRequest

    func testCreateAliasRequest_setsLoadingAndClearsError() {
        var state = HomeState.initial
        state.errorMessage = "Erro"

        let newState = HomeReducer.reduce(state, .createAliasRequest)

        XCTAssertTrue(newState.isLoading)
        XCTAssertNil(newState.errorMessage)
    }

    // MARK: - createAliasSuccess

    func testCreateAliasSuccess_stopsLoadingInsertsAliasClearsInputAndError() {
        var state = HomeState.initial
        state.urlInput = "https://example.com"
        state.isLoading = true
        let alias = URLAlias.fixture(id: "new-id")

        let newState = HomeReducer.reduce(state, .createAliasSuccess(alias))

        XCTAssertFalse(newState.isLoading)
        XCTAssertEqual(newState.aliases.count, 1)
        XCTAssertEqual(newState.aliases.first, alias)
        XCTAssertEqual(newState.urlInput, "")
        XCTAssertNil(newState.errorMessage)
    }

    @MainActor
    func testCreateAliasSuccess_insertsAtBeginning() {
        var state = HomeState.initial
        let existing = URLAlias.fixture(id: "old")
        state.aliases = [existing]
        let newAlias = URLAlias.fixture(id: "new")

        let newState = HomeReducer.reduce(state, .createAliasSuccess(newAlias))

        XCTAssertEqual(newState.aliases.count, 2)
        XCTAssertEqual(newState.aliases[0], newAlias)
        XCTAssertEqual(newState.aliases[1], existing)
    }

    func testCreateAliasSuccess_emptyListBecomesSingleItem() {
        let state = HomeState.initial
        let alias = URLAlias.fixture(id: "1")

        let newState = HomeReducer.reduce(state, .createAliasSuccess(alias))

        XCTAssertEqual(newState.aliases.count, 1)
        XCTAssertEqual(newState.aliases.first?.id, "1")
    }

    // MARK: - deleteAliasSuccess

    func testDeleteAliasSuccess_removesAliasStopsLoadingClearsError() {
        var state = HomeState.initial
        let a1 = URLAlias.fixture(id: "1")
        let a2 = URLAlias.fixture(id: "2")
        state.aliases = [a1, a2]
        state.isLoading = true
        state.errorMessage = "Algum erro"

        let newState = HomeReducer.reduce(state, .deleteAliasSuccess("1"))

        XCTAssertFalse(newState.isLoading)
        XCTAssertEqual(newState.aliases.count, 1)
        XCTAssertEqual(newState.aliases.first?.id, "2")
        XCTAssertNil(newState.errorMessage)
    }

    func testDeleteAliasSuccess_emptyListRemainsEmpty() {
        let state = HomeState.initial

        let newState = HomeReducer.reduce(state, .deleteAliasSuccess("inexistente"))

        XCTAssertTrue(newState.aliases.isEmpty)
        XCTAssertNil(newState.errorMessage)
    }

    func testDeleteAliasSuccess_nonexistentIdRemovesNothing() {
        var state = HomeState.initial
        state.aliases = [URLAlias.fixture(id: "only-one")]

        let newState = HomeReducer.reduce(state, .deleteAliasSuccess("other-id"))

        XCTAssertEqual(newState.aliases.count, 1)
        XCTAssertEqual(newState.aliases.first?.id, "only-one")
    }

    // MARK: - createAliasFailure

    func testCreateAliasFailure_stopsLoadingSetsErrorMessage() {
        var state = HomeState.initial
        state.isLoading = true
        let message = "Falha na rede"

        let newState = HomeReducer.reduce(state, .createAliasFailure(message))

        XCTAssertFalse(newState.isLoading)
        XCTAssertEqual(newState.errorMessage, message)
    }

    // MARK: - clearError

    func testClearError_removesErrorMessage() {
        var state = HomeState.initial
        state.errorMessage = "Erro"

        let newState = HomeReducer.reduce(state, .clearError)

        XCTAssertNil(newState.errorMessage)
    }

    func testClearError_idempotentWhenNoError() {
        let state = HomeState.initial

        let afterFirst = HomeReducer.reduce(state, .clearError)
        let afterSecond = HomeReducer.reduce(afterFirst, .clearError)

        XCTAssertNil(afterFirst.errorMessage)
        XCTAssertNil(afterSecond.errorMessage)
        XCTAssertEqual(afterFirst.urlInput, afterSecond.urlInput)
    }

    // MARK: - Transições encadeadas (fluxo crítico)

    func testChainedFlow_updateInputThenRequestThenSuccess() {
        var state = HomeState.initial
        let alias = URLAlias.fixture(id: "chained")

        state = HomeReducer.reduce(state, .updateURLInput("https://example.com"))
        state = HomeReducer.reduce(state, .createAliasRequest)
        state = HomeReducer.reduce(state, .createAliasSuccess(alias))

        XCTAssertEqual(state.urlInput, "")
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.aliases.count, 1)
        XCTAssertEqual(state.aliases.first?.id, "chained")
        XCTAssertNil(state.errorMessage)
    }

    func testChainedFlow_requestThenFailureThenClearError() {
        var state = HomeState.initial

        state = HomeReducer.reduce(state, .createAliasRequest)
        state = HomeReducer.reduce(state, .createAliasFailure("Erro de servidor"))
        state = HomeReducer.reduce(state, .clearError)

        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.errorMessage)
    }

    // MARK: - Imutabilidade do estado passado

    func testReduce_doesNotMutateInputState() {
        let initialState = HomeState.initial

        _ = HomeReducer.reduce(initialState, .updateURLInput("https://example.com"))

        XCTAssertEqual(initialState.urlInput, "")
    }
}
