import XCTest
@testable import ShortFlow

// MARK: - ShortFlowUITests (UI)
// Testa renderização baseada no estado, interações e labels.
// Strings alinhadas a HomeStrings (título "Short Flow", botão "Encurtar URL", etc.).
// Para cenários de loading/erro com rede controlada, considerar launch arguments + mock.
final class ShortFlowUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Renderização inicial (estado vazio)

    func testInitialScreen_showsTitleAndDescription() {
        XCTAssertTrue(app.staticTexts["Short Flow"].exists)
        XCTAssertTrue(app.staticTexts["Encurte suas URLs favoritas"].exists)
    }

    func testInitialScreen_showsInputAndButton() {
        XCTAssertTrue(app.textFields.element.exists)
        XCTAssertTrue(app.buttons["Encurtar URL"].exists)
    }

    func testEmptyState_isDisplayedWhenNoAliases() {
        XCTAssertTrue(app.staticTexts["Nenhum link encurtado"].exists)
    }

    // MARK: - Estado derivado: botão habilitado/desabilitado

    func testButton_isDisabledWhenInputIsEmpty() {
        let button = app.buttons["Encurtar URL"]
        XCTAssertFalse(button.isEnabled)
    }

    func testButton_isEnabledWhenInputHasText() {
        let textField = app.textFields.element
        let button = app.buttons["Encurtar URL"]

        textField.tap()
        textField.typeText("https://example.com")

        XCTAssertTrue(button.isEnabled)
    }

    // MARK: - Interações do usuário

    func testInputField_acceptsText() {
        let textField = app.textFields.element
        textField.tap()
        textField.typeText("https://example.com")
        XCTAssertEqual(textField.value as? String, "https://example.com")
    }

    func testClearButton_clearsInput() {
        let textField = app.textFields.element
        textField.tap()
        textField.typeText("https://example.com")

        let clearButton = app.buttons["Limpar campo"]
        XCTAssertTrue(clearButton.exists)
        clearButton.tap()

        let value = textField.value as? String
        XCTAssertTrue(value == nil || value == "" || value == "Vazio")
    }

    // MARK: - Acessibilidade (labels refletem estado)

    func testAccessibility_inputFieldHasCorrectLabel() {
        let textField = app.textFields.element
        XCTAssertEqual(textField.label, "Campo de entrada de URL")
    }

    func testAccessibility_shortenButtonExists() {
        XCTAssertTrue(app.buttons["Encurtar URL"].exists)
    }

    // MARK: - Erro + retry (opcional com ambiente de teste)
    // Para validar fluxo completo: falha de rede → alerta "Erro" → "OK" (clearError) → tela editável,
    // use launch argument para injetar ambiente que force falha na API.
}
