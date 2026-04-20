import Foundation

protocol NetworkRequest {
    associatedtype Response: Decodable
    
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Encodable? { get }
    var queryParameters: [String: String]? { get }
}

extension NetworkRequest {
    var headers: [String: String]? {
        ["Content-Type": ContentType.json.rawValue]
    }
    
    var body: Encodable? { nil }
    var queryParameters: [String: String]? { nil }
    
    func buildURLRequest(baseURL: String) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        if let queryParameters = queryParameters {
            urlComponents.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        return request
    }
}
