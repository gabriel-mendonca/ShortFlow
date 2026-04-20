import Foundation

// MARK: - Network Logger Protocol
protocol NetworkLoggerProtocol {
    func logRequest(_ request: URLRequest)
    func logResponse(_ response: HTTPURLResponse, data: Data?)
    func logError(_ error: Error)
}

// swiftlint:disable no_print_statements
final class NetworkLogger: NetworkLoggerProtocol {
    
    private let isEnabled: Bool
    
    // MARK: - Initialization
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    // MARK: - Public Methods
    
    func logRequest(_ request: URLRequest) {
        guard isEnabled else { return }
        
        print("\n🌐 ===== NETWORK REQUEST =====")
        print("📍 URL: \(request.url?.absoluteString ?? "N/A")")
        print("📋 Method: \(request.httpMethod ?? "N/A")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📝 Headers:")
            headers.forEach { print("   \($0.key): \($0.value)") }
        }
        
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Body: \(bodyString)")
        }
        
        print("===========================\n")
    }
    
    func logResponse(_ response: HTTPURLResponse, data: Data?) {
        guard isEnabled else { return }
        
        let statusEmoji = response.statusCode >= 200 && response.statusCode < 300 ? "✅" : "❌"
        
        print("\n\(statusEmoji) ===== NETWORK RESPONSE =====")
        print("📍 URL: \(response.url?.absoluteString ?? "N/A")")
        print("📊 Status Code: \(response.statusCode)")
        
        if let data = data,
           let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Response Data: \(jsonString)")
        }
        
        print("============================\n")
    }
    
    func logError(_ error: Error) {
        guard isEnabled else { return }
        
        print("\n❌ ===== NETWORK ERROR =====")
        print("⚠️ Error: \(error.localizedDescription)")
        print("===========================\n")
    }
}
// swiftlint:enable no_print_statements
