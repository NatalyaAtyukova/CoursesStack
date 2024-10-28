import SwiftUI

struct BloggerTabView: View {
    @ObservedObject var userViewModel: UserViewModel

    var body: some View {
        TabView {
            BloggerDashboardView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text(NSLocalizedString("my_courses_tab", comment: "")) // Локализованный текст "Мои курсы"
                }
            
            CourseAccessRightsView()
                .tabItem {
                    Image(systemName: "lock.fill")
                    Text(NSLocalizedString("access_rights_tab", comment: "")) // Локализованный текст "Права доступа"
                }

            ProfileView(viewModel: ProfileViewModel())
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
