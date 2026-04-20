import Foundation

protocol CreateAliasUseCaseProtocol {
    func execute(url: String) async throws -> URLAlias
}

final class CreateAliasUseCase: CreateAliasUseCaseProtocol {
    
    private let repository: URLRepositoryProtocol
    private let validator: URLValidatorProtocol
    
    init(
        repository: URLRepositoryProtocol,
        validator: URLValidatorProtocol
    ) {
        self.repository = repository
        self.validator = validator
    }
    
    func execute(url: String) async throws -> URLAlias {
        guard validator.isValid(url: url) else {
            throw URLValidationError.invalidFormat
        }
        
        return try await repository.createAlias(for: url)
    }
}

enum URLValidationError: LocalizedError {
    case invalidFormat
    case empty
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "URL inválida. Por favor, insira uma URL válida."
        case .empty:
            return "A URL não pode estar vazia."
        }
    }
}
