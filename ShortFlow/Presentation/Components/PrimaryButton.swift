import SwiftUI

struct PrimaryButton: View {
    
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isEnabled && !isLoading
                    ? Color.purple
                    : Color.gray.opacity(0.5)
            )
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? HomeStrings.Button.processing : HomeStrings.Button.shortenHint)
        .accessibilityAddTraits(isLoading ? .updatesFrequently : [])
    }
}
