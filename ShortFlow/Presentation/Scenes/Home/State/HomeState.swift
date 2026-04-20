import Foundation

struct HomeState: Equatable {
    var urlInput: String = ""
    var aliases: [URLAlias] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    static let initial = HomeState()
}
