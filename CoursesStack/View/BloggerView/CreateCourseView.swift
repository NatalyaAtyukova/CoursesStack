import SwiftUI

struct CreateCourseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BloggerDashboardViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о курсе")) {
                    TextField("Название", text: $title)
                    TextField("Описание", text: $description)
                    TextField("Цена", text: $price)
                        .keyboardType(.decimalPad)
                }
                
                Button(action: {
                    if let coursePrice = Double(price) {
                        viewModel.createCourse(title: title, description: description, price: coursePrice)
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Создать курс")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Создание курса")
        }
    }
}

