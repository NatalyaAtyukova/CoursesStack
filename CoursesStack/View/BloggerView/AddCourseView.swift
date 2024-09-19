import SwiftUI

struct AddCourseView: View {
    @ObservedObject var viewModel: CourseViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var coverImageURL = ""
    
    var body: some View {
        VStack {
            TextField("Название курса", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Описание курса", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Цена курса", text: $price)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("URL обложки курса", text: $coverImageURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: addCourse) {
                Text("Создать курс")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Добавление курса")
    }
    
    func addCourse() {
        guard let coursePrice = Double(price) else { return }
        viewModel.course.title = title
        viewModel.course.description = description
        viewModel.course.price = coursePrice
        viewModel.course.coverImageURL = coverImageURL
        viewModel.saveCourse()
    }
}
