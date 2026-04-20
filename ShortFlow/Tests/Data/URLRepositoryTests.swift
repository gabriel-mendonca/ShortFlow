import XCTest
@testable import ShortFlow

final class URLRepositoryTests: XCTestCase {

    private var sut: URLRepository!
    private var mockClient: MockNetworkClient!

    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
        sut = URLRepository(networkClient: mockClient)
    }

    override func tearDown() {
        sut = nil
        mockClient = nil
        super.tearDown()
    }

    // MARK: - Success

    @MainActor
    func testCreateAlias_success_returnsMappedEntity_andCallsNetworkClientOnce() async throws {
        let dto = try makeDTO(
            alias: "abc",
            selfLink: "https://api/self",
            shortLink: "https://short/abc"
        )

        mockClient.executeResult = .success(dto)

        let result = try await sut.createAlias(for: "https://example.com")

        XCTAssertEqual(result.alias, "abc")
        XCTAssertEqual(result.selfLink, "https://api/self")
        XCTAssertEqual(result.compactLink, "https://short/abc")

        XCTAssertEqual(mockClient.executeCalls.count, 1)
        XCTAssertTrue(mockClient.executeCalls.first is CreateAliasRequest)
    }

    // MARK: - Network Failure

    func testCreateAlias_networkFailure_throwsNetworkError() async {
        mockClient.executeResult = .failure(
            NetworkError.networkFailure(
                NSError(
                    domain: NSURLErrorDomain,
                    code: NSURLErrorNotConnectedToInternet,
                    userInfo: nil
                )
            )
        )

        do {
            _ = try await sut.createAlias(for: "https://example.com")
            XCTFail("Expected NetworkError.networkFailure")
        } catch let error as NetworkError {
            guard case .networkFailure = error else {
                return XCTFail("Expected networkFailure")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertEqual(mockClient.executeCalls.count, 1)
    }

    // MARK: - Server Error

    func testCreateAlias_serverError_throwsNetworkError() async {
        mockClient.executeResult = .failure(
            NetworkError.serverError(statusCode: 500, message: "Internal")
        )

        do {
            _ = try await sut.createAlias(for: "https://example.com")
            XCTFail("Expected NetworkError.serverError")
        } catch let error as NetworkError {
            guard case .serverError(let code, _) = error else {
                return XCTFail("Expected serverError")
            }
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error type")
        }

        XCTAssertEqual(mockClient.executeCalls.count, 1)
    }

    // MARK: - Decoding Error

    func testCreateAlias_decodingError_throwsNetworkError() async {
        mockClient.executeResult = .failure(
            NetworkError.decodingError(
                DecodingError.dataCorrupted(
                    .init(codingPath: [], debugDescription: "test")
                )
            )
        )

        do {
            _ = try await sut.createAlias(for: "https://example.com")
            XCTFail("Expected decodingError")
        } catch let error as NetworkError {
            guard case .decodingError = error else {
                return XCTFail("Expected decodingError")
            }
        } catch {
            XCTFail("Unexpected error type")
        }

        XCTAssertEqual(mockClient.executeCalls.count, 1)
    }
}
