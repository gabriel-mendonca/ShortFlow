import Combine
import Foundation

final class HomeStore: ObservableObject {
    
    @Published private(set) var state: HomeState
    private let createAliasUseCase: CreateAliasUseCaseProtocol
    private let cache: MemoryStoreProtocol
    
    init(
        initialState: HomeState = .initial,
        cache: MemoryStoreProtocol,
        createAliasUseCase: CreateAliasUseCaseProtocol
    ) {
        self.state = initialState
        self.cache = cache
        self.createAliasUseCase = createAliasUseCase
        
        self.state = makeInitialState(from: initialState)
    }
    
    private func makeInitialState(from initial: HomeState) -> HomeState {
        var state = initial
        state.aliases = cache.all()
        return state
    }
    
    @MainActor
    func dispatch(_ action: HomeAction) {
        state = HomeReducer.reduce(state, action)
        handleSideEffects(for: action)
    }
    
    @MainActor
    private func syncStateWithCache() {
        state.aliases = cache.all()
    }
    
    private func handleSideEffects(for action: HomeAction) {
        switch action {
        case .createAliasRequest:
            executeCreateAlias()
        case .createAliasSuccess(let alias):
            cache.add(alias)
            Task { @MainActor in
                syncStateWithCache()
            }
        case .deleteAliasSuccess(let id):
            cache.remove(id: id)
        default:
            break
        }
    }
    
    @MainActor
    private func executeCreateAlias() {
        let url = state.urlInput
        
        Task {
            do {
                let alias = try await createAliasUseCase.execute(url: url)
                dispatch(.createAliasSuccess(alias))
            } catch {
                dispatch(.createAliasFailure(error.localizedDescription))
            }
        }
    }
}
