import SwiftUI

@main
struct ShortFlowApp: App {
    
    @StateObject private var router = DependencyContainer.shared.makeAppRouter()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navigationPath) {
                HomeView(store: DependencyContainer.shared.makeURLManagerStore())
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .environmentObject(router)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView(store: DependencyContainer.shared.makeURLManagerStore())
        case .detail(let alias):
            Text("Detail: \(alias.alias)")
        }
    }
}
