import Foundation

struct HomeReducer {
    
    static func reduce(
        _ state: HomeState,
        _ action: HomeAction
    ) -> HomeState {
        var newState = state
        
        switch action {
        case .updateURLInput(let input):
            newState.urlInput = input
            newState.errorMessage = nil
            
        case .createAliasRequest:
            newState.isLoading = true
            newState.errorMessage = nil
            
        case .createAliasSuccess(let alias):
            newState.isLoading = false
            newState.aliases.insert(alias, at: 0)
            newState.urlInput = ""
            newState.errorMessage = nil
            
        case .deleteAliasSuccess(let id):
            newState.isLoading = false
            newState.aliases.removeAll { $0.id == id }
            newState.errorMessage = nil
            
        case .createAliasFailure(let error):
            newState.isLoading = false
            newState.errorMessage = error
            
        case .clearError:
            newState.errorMessage = nil
        }
        
        return newState
    }
}
