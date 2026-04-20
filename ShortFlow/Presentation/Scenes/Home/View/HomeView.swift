import SwiftUI

struct HomeView: View {
    
    @StateObject private var store: HomeStore
    
    init(store: HomeStore) {
        _store = StateObject(wrappedValue: store)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            ScrollView {
                VStack(spacing: 24) {
                    inputSection
                        .padding(.horizontal)
                        .padding(.top, 24)
                    listSection
                        .padding(.horizontal)
                }
            }
        }
        .background(Color(.systemBackground))
        .errorAlert(
            errorMessage: Binding(
                get: { store.state.errorMessage },
                set: { _ in store.dispatch(.clearError) }
            ),
            onDismiss: { store.dispatch(.clearError) }
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(HomeStrings.Home.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(HomeStrings.Home.headerDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.purple.opacity(0.1))
        .accessibilityAddTraits(.isHeader)
    }
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            URLInputField(
                text: Binding(
                    get: { store.state.urlInput },
                    set: { store.dispatch(.updateURLInput($0)) }
                ),
                placeholder: HomeStrings.TextField.placeholder,
                onSubmit: handleCreateAlias
            )
            
            PrimaryButton(
                title: HomeStrings.Button.shortenTitle,
                isLoading: store.state.isLoading,
                isEnabled: !store.state.urlInput.isEmpty,
                action: handleCreateAlias
            )
        }
    }
    
    private var listSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !store.state.aliases.isEmpty {
                Text(HomeStrings.Home.recentLinksHeader)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                LazyVStack(spacing: 12) {
                    ForEach(store.state.aliases) { alias in
                        AliasCard(alias: alias) {
                            handleDeleteAlias(id: alias.id)
                        }
                    }
                }
            } else {
                EmptyStateView()
                    .padding(.top, 40)
            }
        }
    }
    
    private func handleDeleteAlias(id: String) {
        store.dispatch(.deleteAliasSuccess(id))
    }
    
    private func handleCreateAlias() {
        store.dispatch(.createAliasRequest)
    }
}
