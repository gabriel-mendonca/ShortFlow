import Foundation

enum AppEnvironment: String, CaseIterable {
    case development = "Development"
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://url-shortener-server.onrender.com"
        }
    }
    
    var isLoggingEnabled: Bool {
        switch self {
        case .development:
            return true
        }
    }
    
    var timeout: TimeInterval {
        switch self {
        case .development:
            return 30
        }
    }
}
