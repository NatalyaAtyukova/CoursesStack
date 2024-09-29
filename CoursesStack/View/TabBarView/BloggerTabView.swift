import SwiftUI

struct BloggerTabView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        TabView {
            BloggerDashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }

            ProfileView(viewModel: ProfileViewModel())
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
        }
        .accentColor(.red) // Активный таб будет красным
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = UIColor.white // Цвет неактивных табов
        }
    }
}
