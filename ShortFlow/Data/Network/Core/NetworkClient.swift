import Foundation

protocol NetworkClientProtocol {
    func execute<T: NetworkRequest>(_ request: T) async throws -> T.Response
}

final class NetworkClient: NetworkClientProtocol {
    
    private let session: URLSession
    private let logger: NetworkLoggerProtocol
    private let environment: AppEnvironment
    
    init(
        environment: AppEnvironment,
        session: URLSession = .shared,
        logger: NetworkLoggerProtocol = NetworkLogger()
    ) {
        self.environment = environment
        self.session = session
        self.logger = logger
    }
    
    func execute<T: NetworkRequest>(_ request: T) async throws -> T.Response {
        let urlRequest = try request.buildURLRequest(baseURL: environment.baseURL)
        
        logger.logRequest(urlRequest)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
 
            logger.logResponse(httpResponse, data: data)
            
            try validateResponse(httpResponse, data: data)

            return try decodeResponse(data: data, as: T.Response.self)
            
        } catch let error as NetworkError {
            logger.logError(error)
            throw error
        } catch {
            logger.logError(error)
            throw NetworkError.networkFailure(error)
        }
    }
    
    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        guard (200...299).contains(response.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(
                statusCode: response.statusCode,
                message: message
            )
        }
    }
    
    private func decodeResponse<T: Decodable>(data: Data, as type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
