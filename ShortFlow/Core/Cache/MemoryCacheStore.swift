import Foundation

final class MemoryCacheStore: MemoryStoreProtocol, @unchecked Sendable {
    
    private var items: [URLAlias] = []
    private let lock = NSLock()
    private let maxItems: Int
    
    init(maxItems: Int = 20) {
        self.maxItems = maxItems
    }
    
    func add(_ item: URLAlias) {
        lock.lock()
        defer { lock.unlock() }
        
        if let existingIndex = items.firstIndex(where: { $0.alias == item.alias }) {
            items.remove(at: existingIndex)
        }
        
        items.insert(item, at: 0)
        
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
    }

    func remove(id: String) {
        lock.lock()
        defer { lock.unlock() }
        
        items.removeAll { $0.id == id }
    }
    
    func all() -> [URLAlias] {
        lock.lock()
        defer { lock.unlock() }
        
        return items
    }
   
    func clear() {
        lock.lock()
        defer { lock.unlock() }
        
        items.removeAll()
    }
}
