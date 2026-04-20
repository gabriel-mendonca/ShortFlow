import SwiftUI

struct EmptyStateView: View {
    
    let title: String
    let message: String
    let iconName: String
    
    init(
        title: String = HomeStrings.EmptyState.title,
        message: String = HomeStrings.EmptyState.message,
        iconName: String = "link.circle"
    ) {
        self.title = title
        self.message = message
        self.iconName = iconName
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(HomeStrings.Accessibility.titleAndMessage(title: title, message: message))
    }
}
