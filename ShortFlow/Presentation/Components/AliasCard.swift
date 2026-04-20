import SwiftUI

struct AliasCard: View {
    
    let alias: URLAlias
    var onDelete: (() -> Void)
    @State private var showCopiedFeedback = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(HomeStrings.Home.shortenedLinkSection)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(alias.compactLink)
                        .font(.headline)
                        .foregroundColor(.purple)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    if showCopiedFeedback {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(HomeStrings.AliasCard.copied)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red.opacity(0.8))
                            .padding(8)
                            .background(Color.red.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Excluir alias")
                    .accessibilityHint("Toque duplo para remover este link encurtado")
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(HomeStrings.AliasCard.originalURLLabel)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(alias.originalURL)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Text(formatDate(alias.createdAt))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .onTapGesture {
            copyToClipboard()
        }
        .confirmationDialog(
            HomeStrings.Alert.deleteConfirmationTitle,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(HomeStrings.Alert.delete, role: .destructive) {
                onDelete()
            }
            Button(HomeStrings.Alert.cancel, role: .cancel) {}
        } message: {
            Text(HomeStrings.Alert.deleteConfirmationMessage)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Alias de URL")
        .accessibilityValue("Link encurtado: \(alias.compactLink). URL original: \(alias.originalURL)")
        .accessibilityHint("Toque duplo para copiar o link encurtado")
        .accessibilityAddTraits(.isButton)
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = alias.compactLink
        
        withAnimation(.spring(response: 0.3)) {
            showCopiedFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedFeedback = false
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
