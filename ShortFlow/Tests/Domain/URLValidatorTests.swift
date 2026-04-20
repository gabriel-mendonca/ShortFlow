import XCTest
@testable import ShortFlow

final class URLValidatorTests: XCTestCase {

    private var sut: URLValidator!

    override func setUp() {
        super.setUp()
        sut = URLValidator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - URLs válidas
    func testValidHTTPURL() {
        XCTAssertTrue(sut.isValid(url: "http://example.com"))
    }
    
    func testValidHTTPSURL() {
        XCTAssertTrue(sut.isValid(url: "https://example.com"))
    }
    
    func testValidURLWithPath() {
        XCTAssertTrue(sut.isValid(url: "https://example.com/path/to/resource"))
    }
    
    func testValidURLWithQuery() {
        XCTAssertTrue(sut.isValid(url: "https://example.com/?param=value"))
    }

    func testValidURLWithFragment() {
        XCTAssertTrue(sut.isValid(url: "https://example.com/#section"))
    }
    
    func testValidURLWithSubdomain() {
        XCTAssertTrue(sut.isValid(url: "https://subdomain.example.com"))
    }
    
    func testValidURLWithPort() {
        XCTAssertTrue(sut.isValid(url: "https://example.com:8080"))
    }
    
    // MARK: - Invalid URLs Tests
    func testInvalidEmptyURL() {
        XCTAssertFalse(sut.isValid(url: ""))
    }
    
    func testInvalidWhitespaceURL() {
        XCTAssertFalse(sut.isValid(url: "   "))
    }
    
    func testInvalidNoScheme() {
        XCTAssertFalse(sut.isValid(url: "://example.com"))
    }

    func testInvalidScheme() {
        XCTAssertFalse(sut.isValid(url: "ftp://example.com"))
    }
    
    func testInvalidNoHost() {
        XCTAssertFalse(sut.isValid(url: "https://"))
    }
    
    func testInvalidMalformed() {
        XCTAssertFalse(sut.isValid(url: "not-a-url"))
    }
    
    func testInvalidSpaces() {
        XCTAssertFalse(sut.isValid(url: "https://example with spaces.com"))
    }

    // MARK: - Edge cases (caracteres inválidos, trim)

    func testValidURL_withNewline_trimmed() {
        XCTAssertTrue(sut.isValid(url: "https://example.com\n"))
    }

    func testValidURL_withTab_trimmed() {
        XCTAssertTrue(sut.isValid(url: "https://example.com\t"))
    }

    func testValidURL_trimmedWhitespace() {
        XCTAssertTrue(sut.isValid(url: "  https://example.com  "))
    }

    func testInvalidURL_withAngleBrackets() {
        XCTAssertFalse(sut.isValid(url: "https://<example>.com"))
    }

    func testInvalidURL_withComma() {
        XCTAssertFalse(sut.isValid(url: "https://example.com,path"))
    }

    func testValidURL_withoutScheme_addsHttps() {
        XCTAssertTrue(sut.isValid(url: "example.com"))
    }
}
