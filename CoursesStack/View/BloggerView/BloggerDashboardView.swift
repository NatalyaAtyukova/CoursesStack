import SwiftUI

struct BloggerDashboardView: View {
    @StateObject private var viewModel = BloggerDashboardViewModel()
    @State private var showingCreateCourse = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.courses.isEmpty {
                    Text("У вас пока нет курсов")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    List(viewModel.courses) { course in
                        NavigationLink(destination: CourseDetailView(viewModel: CourseDetailViewModel(course: course))) {
                            CourseRow(course: course)
                                .padding(.vertical, 8)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
                
                Button(action: {
                    showingCreateCourse.toggle()
                }) {
                    Text("Создать курс")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                }
                .sheet(isPresented: $showingCreateCourse) {
                    CreateCourseView(viewModel: viewModel)
                }
                .padding(.bottom, 20)
            }
            .background(Color(white: 0.95))
            .navigationTitle("Курсы")
            .onAppear {
                viewModel.fetchCourses()
            }
            .errorAlert($viewModel.errorMessage)
        }
    }
}
