import SwiftUI

struct BloggerTabView: View {
    @ObservedObject var userViewModel: UserViewModel // Здесь используем правильное имя параметра
    
    var body: some View {
        TabView {
            BloggerDashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }

            ProfileView(viewModel: ProfileViewModel()) // Используем ProfileViewModel для профиля
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
        }
    }
}
