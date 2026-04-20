import XCTest
@testable import ShortFlow

final class CreateAliasResponseDTOMappingTests: XCTestCase {

    // MARK: - Happy Path

    func test_toDomain_mapsAllFieldsCorrectly() throws {
        let dto = try makeDTO(
            alias: "abc123",
            selfLink: "https://api.example.com/alias/abc123",
            shortLink: "https://short.link/abc123"
        )

        let entity = dto.toDomain()

        XCTAssertEqual(entity.alias, "abc123")
        XCTAssertEqual(entity.originalURL, "https://api.example.com/alias/abc123")
        XCTAssertEqual(entity.selfLink, "https://api.example.com/alias/abc123")
        XCTAssertEqual(entity.compactLink, "https://short.link/abc123")

        XCTAssertValidUUID(entity.id)
        XCTAssertNotNil(entity.createdAt)
    }

    // MARK: - Identity Rules

    func test_toDomain_generatesValidUUIDIdentifier() throws {
        let dto = try makeDTO(alias: "x")
        let entity = dto.toDomain()

        XCTAssertValidUUID(entity.id)
    }
}
