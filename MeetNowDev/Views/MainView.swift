import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    @State private var userRole: RoleSelectionView.UserRole = .poster
    @StateObject private var userProfile = UserProfile.mock // 使用模拟数据，实际应从用户配置中读取
    
    // 监听用户角色变化
    private func updateUserRole(_ newRole: RoleSelectionView.UserRole) {
        userRole = newRole
        userProfile.role = newRole
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页（订单列表）
            if userRole == .poster {
                PostOrderView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("发布约见")
                    }
                    .tag(0)
            } else {
                OrderDiscoveryView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("接单列表")
                    }
                    .tag(0)
            }
            
            // 聊天列表
            ChatListView()
                .tabItem {
                    Image(systemName: "message")
                    Text("聊天")
                }
                .tag(1)
            
            // 个人中心
            ProfileView(currentRole: $userRole)
                .tabItem {
                    Image(systemName: "person")
                    Text("我的")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainView()
}