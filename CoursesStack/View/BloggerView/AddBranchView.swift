import SwiftUI

struct AddBranchView: View {
    @ObservedObject var viewModel: CourseDetailViewModel
    @State private var branchTitle = ""
    @State private var branchDescription = ""
    
    var body: some View {
        VStack {
            TextField("Название ветки", text: $branchTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Описание ветки", text: $branchDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                viewModel.addBranch(title: branchTitle, description: branchDescription) // Вызываем метод addBranch
            }) {
                Text("Добавить ветку")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Добавление ветки")
    }
}
