import Foundation

final class DependencyContainer {
    
    static let shared = DependencyContainer()
    
    private let networkClient: NetworkClientProtocol
    private let urlRepository: URLRepositoryProtocol
    private let urlValidator: URLValidatorProtocol
    private let createAliasUseCase: CreateAliasUseCaseProtocol
    private let memoryURLCache: MemoryStoreProtocol
    
    private init() {
        let environment = EnvironmentManager.shared.current
        let logger = NetworkLogger(isEnabled: environment.isLoggingEnabled)
        self.networkClient = NetworkClient(environment: environment, logger: logger)
        self.urlRepository = URLRepository(networkClient: networkClient)
        self.urlValidator = URLValidator()
        self.createAliasUseCase = CreateAliasUseCase(
            repository: urlRepository,
            validator: urlValidator
        )
        self.memoryURLCache = MemoryCacheStore(maxItems: 50)
    }
    
    // MARK: - Factory Methods
    func makeURLManagerStore() -> HomeStore {
        HomeStore(cache: memoryURLCache, createAliasUseCase: createAliasUseCase)
    }
    
    func makeAppRouter() -> AppRouter {
        AppRouter()
    }
}
