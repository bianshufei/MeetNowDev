import SwiftUI

/// 主视图
/// 这是应用的根视图，负责管理整个应用的主要导航和标签页切换
/// 包含三个主要标签页：
/// 1. 订单页面（根据用户角色显示发单或接单界面）
/// 2. 聊天列表页面
/// 3. 个人中心页面
struct MainView: View {
    /// 当前选中的标签页索引
    @State private var selectedTab = 0
    /// 当前用户角色（发单人/接单人）
    @State private var userRole: RoleSelectionView.UserRole = {
        // 从UserDefaults中读取用户角色
        if let roleString = UserDefaults.standard.string(forKey: "userRole") {
            return roleString == "poster" ? .poster : .taker
        }
        return .poster // 默认为发单人
    }()
    /// 用户档案数据，目前使用模拟数据，后续需要从服务器获取
    @StateObject private var userProfile = UserProfile.mock
    
    /// 处理用户角色切换的方法
    /// 当用户在个人中心切换角色时，同步更新用户档案中的角色信息
    /// - Parameter newRole: 新的用户角色
    private func updateUserRole(_ newRole: RoleSelectionView.UserRole) {
        userRole = newRole
        userProfile.role = newRole
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - 订单页面（根据角色动态切换）
            // 当用户是发单人时显示发单界面，是接单人时显示接单列表
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
            
            // MARK: - 聊天列表页面
            // 显示用户的所有聊天会话列表
            ChatListView()
                .tabItem {
                    Image(systemName: "message")
                    Text("聊天")
                }
                .tag(1)
            
            // MARK: - 个人中心页面
            // 显示用户个人信息、角色管理和应用设置
            ProfileView(currentRole: Binding(
                get: { userRole },
                set: { updateUserRole($0) }
            ))
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