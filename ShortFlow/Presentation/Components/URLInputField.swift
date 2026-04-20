import SwiftUI

struct URLInputField: View {
    
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.gray.opacity(0.6))
                }
                .textFieldStyle(.plain)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .submitLabel(.done)
                .onSubmit(onSubmit)
                .accessibilityLabel(HomeStrings.TextField.accessibilityLabel)
                .accessibilityHint(HomeStrings.TextField.placeholder)
                .accessibilityValue(text.isEmpty ? HomeStrings.TextField.emptyValue : text)
            
            if !text.isEmpty {
                Button(action: { text = "" }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.6))
                })
                .accessibilityLabel(HomeStrings.TextField.clearButton)
                .accessibilityHint(HomeStrings.TextField.clearButtonHint)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}
