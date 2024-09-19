import SwiftUI

struct UserTabView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var profileViewModel = ProfileViewModel() // Отдельная ViewModel для профиля
    
    var body: some View {
        TabView {
            UserCoursesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Курсы")
                }

            ProfileView(viewModel: profileViewModel) // Используем ProfileViewModel для профиля
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
        }
    }
}
