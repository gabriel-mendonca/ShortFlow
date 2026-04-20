import Combine
import Foundation

class EnvironmentManager: ObservableObject {
    static let shared = EnvironmentManager()
    
    @Published var current: AppEnvironment {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "selectedEnvironment")
        }
    }
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: "selectedEnvironment")
        self.current = AppEnvironment(rawValue: saved ?? "") ?? .development
    }
}
