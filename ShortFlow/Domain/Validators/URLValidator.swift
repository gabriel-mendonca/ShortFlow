import Foundation

protocol URLValidatorProtocol {
    func isValid(url: String) -> Bool
}

final class URLValidator: URLValidatorProtocol {
    
    private let urlRegex = #/^https?:\/\/([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(:\d+)?(\/.*)?$/#
    
    private let invalidURLCharacters = CharacterSet(charactersIn: ",\n\r\t<>\"'\\")
    
    func isValid(url: String) -> Bool {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return false }
        
        guard !containsInvalidURLCharacters(trimmed) else { return false }
        
        let normalized = addSchemeIfNeeded(trimmed)
        
        guard normalized.wholeMatch(of: urlRegex) != nil else { return false }
        
        guard
            let url = URL(string: normalized),
            let scheme = url.scheme?.lowercased(),
            ["http", "https"].contains(scheme),
            url.host != nil
        else {
            return false
        }
        
        return true
    }
    
    private func containsInvalidURLCharacters(_ string: String) -> Bool {
        string.unicodeScalars.contains { invalidURLCharacters.contains($0) }
    }
    
    private func addSchemeIfNeeded(_ urlString: String) -> String {
        let lowercased = urlString.lowercased()
        
        if lowercased.hasPrefix("http://") || lowercased.hasPrefix("https://") {
            return urlString
        }
        
        return "https://\(urlString)"
    }
}
