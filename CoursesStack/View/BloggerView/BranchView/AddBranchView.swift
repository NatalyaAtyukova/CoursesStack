import SwiftUI

struct AddBranchView: View {
    @ObservedObject var viewModel: CourseDetailViewModel
    @State private var branchTitle = ""
    @State private var branchDescription = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                TextField("Название ветки", text: $branchTitle)
                TextField("Описание ветки", text: $branchDescription)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            
            Button(action: {
                viewModel.addBranch(title: branchTitle, description: branchDescription)
            }) {
                Text("Добавить ветку")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .background(Color(white: 0.95).edgesIgnoringSafeArea(.all))
        .navigationTitle("Добавление ветки")
    }
}
