import SwiftUI

struct AlertMessage: Identifiable {
    var id = UUID() // Уникальный идентификатор
    var message: String
}

struct AlertView: ViewModifier {
    @Binding var alertMessage: AlertMessage? // Привязка к модели ошибки
    
    func body(content: Content) -> some View {
        content
            .alert(item: $alertMessage) { alertMessage in
                Alert(
                    title: Text("Ошибка"),
                    message: Text(alertMessage.message),
                    dismissButton: .default(Text("ОК"))
                )
            }
    }
}

// Модификатор для упрощения вызова в View
extension View {
    func errorAlert(_ alertMessage: Binding<AlertMessage?>) -> some View {
        self.modifier(AlertView(alertMessage: alertMessage))
    }
}
