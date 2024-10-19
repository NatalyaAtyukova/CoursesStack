import SwiftUI

struct MyCourseDetailView: View {
    @ObservedObject var viewModel: MyCourseDetailViewModel
    @State private var selectedLesson: Lesson?
    @State private var showingLessonDetail = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                // Отображение обложки курса
                if let imageURL = URL(string: viewModel.course.coverImageURL) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .clipped()
                                .shadow(radius: 5)
                                .frame(maxWidth: .infinity)
                        case .failure:
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                // Отображение основной информации о курсе
                Text(viewModel.course.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                Text(viewModel.course.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                
                Text("Цена: \(viewModel.course.price, specifier: "%.2f") \(viewModel.course.currency.symbol)")
                    .font(.title2)
                    .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
                    .padding(.top, 8)
                
                Divider()
                
                // Отображение веток курса
                Text("Шаги курса")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                if !viewModel.course.branches.isEmpty {
                    ForEach(viewModel.course.branches) { branch in
                        VStack(alignment: .leading, spacing: 10) {
                            BranchCard(
                                branch: branch,
                                isCompleted: viewModel.course.completedBranches[branch.id] ?? false,
                                description: branch.description,
                                onLessonTap: { lesson in
                                    selectedLesson = lesson
                                    showingLessonDetail = true
                                }
                            )
                            
                            Text("Уроки:")
                                .font(.subheadline)
                                .padding(.top, 8)
                            
                            ForEach(branch.lessons) { lesson in
                                LessonCard(lesson: lesson)
                                    .onTapGesture {
                                        selectedLesson = lesson
                                        showingLessonDetail = true
                                    }
                            }
                        }
                    }
                } else {
                    Text("Нет доступных веток курса")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .background(Color(red: 44/255, green: 44/255, blue: 46/255)) // Темный фон для экрана
        .sheet(item: $selectedLesson) { lesson in
            // Открываем новое представление только для просмотра
            MyLessonDetailView(viewModel: LessonDetailViewModel(lesson: lesson, courseService: CourseService()))
        }
    }
}