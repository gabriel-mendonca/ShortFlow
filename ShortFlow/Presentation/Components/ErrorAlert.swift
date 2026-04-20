import SwiftUI

struct ErrorAlert: ViewModifier {
    
    @Binding var errorMessage: String?
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert(HomeStrings.Alert.errorTitle, isPresented: .constant(errorMessage != nil)) {
                Button(HomeStrings.Alert.ok, role: .cancel) {
                    onDismiss()
                }
            } message: {
                if let message = errorMessage {
                    Text(message)
                }
            }
    }
}

extension View {
    func errorAlert(
        errorMessage: Binding<String?>,
        onDismiss: @escaping () -> Void
    ) -> some View {
        modifier(ErrorAlert(errorMessage: errorMessage, onDismiss: onDismiss))
    }
}
