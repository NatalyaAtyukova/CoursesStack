import SwiftUI

struct MyCourseDetailView: View {
    @ObservedObject var viewModel: MyCourseDetailViewModel
    @State private var selectedLesson: Lesson?
    @State private var showingLessonDetail = false
    @State private var showingReviewView = false  // Для управления отображением окна отзывов

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

                // Основная информация о курсе
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

                Text(String(format: NSLocalizedString("price_label", comment: ""), viewModel.course.price, viewModel.course.currency.symbol))
                    .font(.title2)
                    .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
                    .padding(.top, 8)

                Divider()

                // Отображение веток курса
                Text(NSLocalizedString("course_steps_label", comment: ""))
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

                            Text(NSLocalizedString("lessons_label", comment: ""))
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
                    Text(NSLocalizedString("no_course_branches", comment: ""))
                        .font(.body)
                        .foregroundColor(.gray)
                }

                Divider()

                // Кнопка для перехода к отзывам
                Button(action: {
                    showingReviewView = true
                }) {
                    Text(NSLocalizedString("reviews_button", comment: ""))
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color(red: 44/255, green: 44/255, blue: 46/255)) // Темный фон для экрана
        .sheet(item: $selectedLesson) { lesson in
            MyLessonDetailView(viewModel: LessonDetailViewModel(lesson: lesson, courseService: CourseService()))
        }
        .sheet(isPresented: $showingReviewView) {
            ReviewsView(viewModel: viewModel)  // Переход к отдельному представлению отзывов
        }
    }
}
