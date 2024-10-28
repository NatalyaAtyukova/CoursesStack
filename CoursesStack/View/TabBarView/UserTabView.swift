import SwiftUI

struct UserTabView: View {
    @ObservedObject var userViewModel = UserViewModel()
    @ObservedObject var profileViewModel = ProfileViewModel() // ViewModel для профиля
    
    var body: some View {
        TabView {
            // Вкладка "Мои курсы" для пользователей
            UserCoursesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text(NSLocalizedString("user_courses_tab", comment: "")) // Локализованный текст "Мои курсы"
                }
            
            // Проверка на наличие выбранного курса
            if let selectedCourse = userViewModel.selectedCourse {
                CourseDetailView(viewModel: CourseDetailViewModel(course: selectedCourse))
                    .tabItem {
                        Image(systemName: "doc.text.fill")
                        Text(NSLocalizedString("course_management_tab", comment: "")) // Локализованный текст "Управление курсами"
                    }
            }
            
            // Вкладка для просмотра всех курсов
            AllCoursesView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text(NSLocalizedString("all_courses_tab", comment: "")) // Локализованный текст "Все курсы"
                }
            
            // Вкладка "Профиль"
            ProfileView(viewModel: profileViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text(NSLocalizedString("profile_tab", comment: "")) // Локализованный текст "Профиль"
                }
        }
        .accentColor(.red)
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = UIColor.white
        }
    }
}
