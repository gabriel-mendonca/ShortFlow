import Combine
import SwiftUI

enum AppRoute: Hashable {
    case home
    case detail(URLAlias)
}

@MainActor
final class AppRouter: ObservableObject {
    
    @Published var navigationPath = NavigationPath()
    
    func navigate(to route: AppRoute) {
        navigationPath.append(route)
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
