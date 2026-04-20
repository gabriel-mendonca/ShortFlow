import Foundation

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Network Error
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case networkFailure(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida."
        case .noData:
            return "Nenhum dado recebido do servidor."
        case .decodingError(let error):
            return "Erro ao processar resposta: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            let baseMessage = "Erro no servidor (\(statusCode))"
            return message.map { "\(baseMessage): \($0)" } ?? baseMessage
        case .networkFailure(let error):
            return "Falha na conexão: \(error.localizedDescription)"
        case .unknown:
            return "Erro desconhecido."
        }
    }
}

// MARK: - Content Type
enum ContentType: String {
    case json = "application/json"
    case formUrlEncoded = "application/x-www-form-urlencoded"
}
