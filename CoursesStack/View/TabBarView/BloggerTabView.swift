import SwiftUI

struct BloggerTabView: View {
    @ObservedObject var userViewModel: UserViewModel

    var body: some View {
        TabView {
            BloggerDashboardView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Мои курсы")
                }
            
            CourseAccessRightsView()
                .tabItem {
                    Image(systemName: "lock.fill")
                    Text("Права доступа")
                }

            ProfileView(viewModel: ProfileViewModel())
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
