@testable import ShortFlow

final class URLValidatorStub: URLValidatorProtocol {

    var isValidResult: Bool = true
    private(set) var validatedURLs: [String] = []

    func isValid(url: String) -> Bool {
        validatedURLs.append(url)
        return isValidResult
    }
}
