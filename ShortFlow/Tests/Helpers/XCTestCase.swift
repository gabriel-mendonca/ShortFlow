
import XCTest
import Combine
@testable import ShortFlow

extension XCTestCase {
    func XCTAssertThrowsErrorAsync<T>(
        _ expression: @autoclosure () async throws -> T,
        _ handler: (Error) -> Void
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error but succeeded")
        } catch {
            handler(error)
        }
    }
    
    @MainActor
    func awaitState(
            _ store: HomeStore,
            where predicate: @escaping (HomeState) -> Bool,
            timeout: TimeInterval = 1
        ) async {

            let expectation = XCTestExpectation(description: "Awaiting state")

            let cancellable = store.$state
                .dropFirst()
                .sink { state in
                    if predicate(state) {
                        expectation.fulfill()
                    }
                }

            await fulfillment(of: [expectation], timeout: timeout)
            cancellable.cancel()
        }
    
    func makeDTO(
        alias: String = "default",
        selfLink: String = "https://default/self",
        shortLink: String = "https://default/short"
    ) throws -> CreateAliasResponseDTO {

        return CreateAliasResponseDTO(
            alias: alias,
            links: LinksDTO(
                selfLink: selfLink,
                compact: shortLink
            )
        )
    }

    func XCTAssertValidUUID(
        _ value: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNotNil(
            UUID(uuidString: value),
            "Expected a valid UUID but received \(value)",
            file: file,
            line: line
        )
    }
}

