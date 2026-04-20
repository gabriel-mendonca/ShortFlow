import Foundation

protocol MemoryStoreProtocol: Sendable {
    func add(_ item: URLAlias)
    func remove(id: String)
    func all() -> [URLAlias]
    func clear()
}
