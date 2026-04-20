import Foundation

enum HomeStrings {

    // MARK: - Home
    enum Home {
        /// "Encurte suas URLs favoritas"
        static var headerDescription: String {
            String(localized: "Encurte suas URLs favoritas")
        }

        /// "Short Flow"
        static var title: String {
            String(localized: "Short Flow")
        }

        /// "Links Recentes"
        static var recentLinksHeader: String {
            String(localized: "Links Recentes")
        }

        /// "Link Encurtado"
        static var shortenedLinkSection: String {
            String(localized: "Link Encurtado")
        }
    }

    // MARK: - TextField
    enum TextField {
        /// "Digite a URL que deseja encurtar"
        static var placeholder: String {
            String(localized: "Digite a URL que deseja encurtar")
        }

        /// "Campo de entrada de URL"
        static var accessibilityLabel: String {
            String(localized: "Campo de entrada de URL")
        }

        /// "Vazio"
        static var emptyValue: String {
            String(localized: "Vazio")
        }

        /// "Limpar campo"
        static var clearButton: String {
            String(localized: "Limpar campo")
        }

        /// "Remove o texto digitado"
        static var clearButtonHint: String {
            String(localized: "Remove o texto digitado")
        }
    }

    // MARK: - Button
    enum Button {
        /// "Encurtar URL"
        static var shortenTitle: String {
            String(localized: "Encurtar URL")
        }

        /// "Toque para encurtar a URL"
        static var shortenHint: String {
            String(localized: "Toque para encurtar a URL")
        }

        /// "Processando"
        static var processing: String {
            String(localized: "Processando")
        }
    }

    // MARK: - EmptyState
    enum EmptyState {
        /// "Nenhum link encurtado"
        static var title: String {
            String(localized: "Nenhum link encurtado")
        }

        /// "Comece digitando uma URL acima para criar seu primeiro link encurtado."
        static var message: String {
            String(localized: "Comece digitando uma URL acima para criar seu primeiro link encurtado.")
        }
    }

    // MARK: - AliasCard
    enum AliasCard {
        /// "Alias de URL"
        static var viewTitle: String {
            String(localized: "Alias de URL")
        }

        /// "URL Original"
        static var originalURLLabel: String {
            String(localized: "URL Original")
        }

        /// "Copiado"
        static var copied: String {
            String(localized: "Copiado")
        }

        /// "Toque duplo para copiar o link encurtado"
        static var copyHint: String {
            String(localized: "Toque duplo para copiar o link encurtado")
        }

        /// "Toque duplo para remover este link encurtado"
        static var deleteHint: String {
            String(localized: "Toque duplo para remover este link encurtado")
        }

        /// "Link encurtado: %1$@. URL original: %2$@"
        static func accessibilityDescription(shortLink: String, originalURL: String) -> String {
            String(format: String(localized: "Link encurtado: %@. URL original: %@"), shortLink, originalURL)
        }
    }

    // MARK: - Detail
    enum Detail {
        /// "Detail: %@"
        static func title(alias: String) -> String {
            String(format: String(localized: "Detail: %@"), alias)
        }
    }

    // MARK: - Alert
    enum Alert {
        /// "Erro"
        static var errorTitle: String {
            String(localized: "Erro")
        }

        /// "OK"
        static var ok: String {
            String(localized: "OK")
        }

        /// "Excluir link encurtado?"
        static var deleteConfirmationTitle: String {
            String(localized: "Excluir link encurtado?")
        }

        /// "Esta ação não pode ser desfeita."
        static var deleteConfirmationMessage: String {
            String(localized: "Esta ação não pode ser desfeita.")
        }

        /// "Excluir"
        static var delete: String {
            String(localized: "Excluir")
        }

        /// "Excluir alias"
        static var deleteAlias: String {
            String(localized: "Excluir alias")
        }

        /// "Cancelar"
        static var cancel: String {
            String(localized: "Cancelar")
        }
    }

    // MARK: - Accessibility
    enum Accessibility {
        /// "%1$@. %2$@" — combines title and message for accessibility clients
        static func titleAndMessage(title: String, message: String) -> String {
            String(format: String(localized: "%@. %@"), title, message)
        }
    }
}
