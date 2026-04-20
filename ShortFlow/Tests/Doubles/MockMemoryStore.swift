import Foundation

final class MockMemoryStore: MemoryStoreProtocol, @unchecked Sendable {

    var storedAliases: [URLAlias] = []
    var addCalls: [URLAlias] = []
    var removeCalls: [String] = []

    func add(_ item: URLAlias) {
        addCalls.append(item)
        if let index = storedAliases.firstIndex(where: { $0.id == item.id }) {
            storedAliases.remove(at: index)
        }
        storedAliases.insert(item, at: 0)
    }

    func remove(id: String) {
        removeCalls.append(id)
        storedAliases.removeAll { $0.id == id }
    }

    func all() -> [URLAlias] {
        storedAliases
    }

    func clear() {
        storedAliases.removeAll()
        addCalls.removeAll()
        removeCalls.removeAll()
    }
}
