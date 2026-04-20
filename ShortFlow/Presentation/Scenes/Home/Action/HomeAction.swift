import Foundation

enum HomeAction {
    case updateURLInput(String)
    case createAliasRequest
    case createAliasSuccess(URLAlias)
    case deleteAliasSuccess(String)
    case createAliasFailure(String)
    case clearError
}
