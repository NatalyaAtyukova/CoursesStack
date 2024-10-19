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
                    Text("Мои курсы")
                }
            
            // Проверка на наличие выбранного курса
            if let selectedCourse = userViewModel.selectedCourse {
                CourseDetailView(viewModel: CourseDetailViewModel(course: selectedCourse))
                    .tabItem {
                        Image(systemName: "doc.text.fill")
                        Text("Управление курсами")
                    }
            }
            
            // Вкладка "Профиль"
            ProfileView(viewModel: profileViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
        }
        .accentColor(.red)
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = UIColor.white
        }
    }
}
