import XCTest
@testable import ShortFlow

final class CreateAliasUseCaseTests: XCTestCase {

    // MARK: - Properties

    private var sut: CreateAliasUseCase!
    private var repositorySpy: URLRepositorySpy!
    private var validatorStub: URLValidatorStub!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        let components = makeSUT()
        sut = components.sut
        repositorySpy = components.repository
        validatorStub = components.validator
    }

    override func tearDown() {
        sut = nil
        repositorySpy = nil
        validatorStub = nil
        super.tearDown()
    }

    // MARK: - Success Scenarios

    @MainActor
    func test_execute_whenURLIsValid_returnsAlias() async throws {
        let url = URLFixture.valid
        let expectedAlias = URLAlias.fixture(originalURL: url)
        validatorStub.isValidResult = true
        repositorySpy.result = .success(expectedAlias)

        let result = try await sut.execute(url: url)

        XCTAssertEqual(result, expectedAlias)
    }

    @MainActor
    func test_execute_whenURLIsValid_callsValidatorAndRepository() async throws {
        let url = URLFixture.valid
        validatorStub.isValidResult = true
        repositorySpy.result = .success(.fixture(originalURL: url))

        _ = try await sut.execute(url: url)

        XCTAssertEqual(validatorStub.validatedURLs, [url])
        XCTAssertEqual(repositorySpy.receivedURLs, [url])
    }

    // MARK: - Validation Rules

    func test_execute_whenURLIsInvalid_throwsInvalidFormat() async {
        validatorStub.isValidResult = false

        await XCTAssertThrowsErrorAsync(
            try await sut.execute(url: "invalid")
        ) { error in
            XCTAssertEqual(error as? URLValidationError, .invalidFormat)
        }

        XCTAssertTrue(repositorySpy.receivedURLs.isEmpty)
    }

    // MARK: - Repository Errors

    func test_execute_whenRepositoryFails_propagatesError() async {
        validatorStub.isValidResult = true
        repositorySpy.result = .failure(NetworkError.unknown)

        await XCTAssertThrowsErrorAsync(
            try await sut.execute(url: URLFixture.valid)
        ) { error in
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    private func makeSUT() -> (sut: CreateAliasUseCase,
                               repository: URLRepositorySpy,
                               validator: URLValidatorStub) {

        let repository = URLRepositorySpy()
        let validator = URLValidatorStub()
        let sut = CreateAliasUseCase(
            repository: repository,
            validator: validator
        )

        return (sut, repository, validator)
    }

}

