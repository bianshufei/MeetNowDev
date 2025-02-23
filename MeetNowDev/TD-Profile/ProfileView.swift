import SwiftUI

/// 个人中心视图
/// 用户可以在此页面：
/// 1. 查看和编辑个人信息（头像、昵称等）
/// 2. 切换用户角色（发单人/接单人）
/// 3. 管理应用设置
/// 4. 执行退出登录操作
struct ProfileView: View {
    /// 当前用户角色，与主视图共享状态
    @Binding var currentRole: RoleSelectionView.UserRole
    /// 控制角色切换确认弹窗的显示状态
    @State private var showRoleToggleAlert = false
    /// 用户档案数据
    @State private var userProfile: UserProfile
    /// 控制编辑个人资料页面的显示状态
    @State private var showEditProfile = false
    /// 订单统计数据
    @State private var orderStats = OrderStats(totalOrders: 0, completedOrders: 0, pendingOrders: 0)
    /// 订单服务
    @StateObject private var orderService = OrderService.shared
    
    /// 初始化个人中心视图
    /// - Parameter currentRole: 当前用户角色的绑定值
    init(currentRole: Binding<RoleSelectionView.UserRole>) {
        _currentRole = currentRole
        // 使用模拟数据初始化用户档案，实际应用中需要从用户配置或服务器获取
        _userProfile = State(initialValue: UserProfile.mock)
    }
    
    var body: some View {
        NavigationView {
            List {
                // 用户信息区域
                Section(header: Text("个人信息")) {
                    Button(action: { showEditProfile = true }) {
                        HStack(spacing: 16) {
                            if let avatarUrl = userProfile.avatarUrl {
                                AsyncImage(url: URL(string: avatarUrl)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure(_):
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.blue)
                                    case .empty:
                                        ProgressView()
                                    @unknown default:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.blue)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(userProfile.nickname)
                                    .font(.headline)
                                HStack(spacing: 4) {
                                    Text(userProfile.gender == .male ? "♂" : "♀")
                                        .foregroundColor(userProfile.gender == .male ? .blue : .pink)
                                    Text("\(userProfile.age)岁")
                                        .foregroundColor(.gray)
                                }
                                .font(.subheadline)
                                Text("电话：\(userProfile.phoneNumber.prefix(3))****\(userProfile.phoneNumber.suffix(4))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                    .foregroundColor(.primary)
                }
                
                // 订单统计区域
                Section(header: Text("订单统计")) {
                    HStack(spacing: 20) {
                        OrderStatsCard(title: "总订单", count: orderStats.totalOrders)
                        OrderStatsCard(title: "已完成", count: orderStats.completedOrders)
                        OrderStatsCard(title: "进行中", count: orderStats.pendingOrders)
                    }
                    .padding(.vertical, 8)
                }
                
                // 身份切换区域
                Section(header: Text("身份管理")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("当前身份")
                                .font(.headline)
                            Text(currentRole == .poster ? "发单人" : "接单人")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button("切换") {
                            showRoleToggleAlert = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // 其他设置项
                Section(header: Text("设置")) {
                    NavigationLink(destination: AccountSecurityView()) {
                        Label("账户与安全", systemImage: "lock.shield")
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        Label("隐私设置", systemImage: "hand.raised")
                    }
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        Label("通知设置", systemImage: "bell")
                    }
                    
                    NavigationLink(destination: AboutUsView()) {
                        Label("关于我们", systemImage: "info.circle")
                    }
                    
                    NavigationLink(destination: Text("帮助中心")) {
                        Label("帮助中心", systemImage: "questionmark.circle")
                    }
                }
                
                // 退出登录
                Section {
                    Button(action: {
                        // TODO: 实现退出登录逻辑
                    }) {
                        Text("退出登录")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("个人中心")
            .navigationDestination(isPresented: $showEditProfile) {
                EditProfileView(userProfile: $userProfile)
            }
            .alert("切换身份", isPresented: $showRoleToggleAlert) {
                Button("确认") {
                    currentRole = currentRole == .poster ? .taker : .poster
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("是否切换到" + (currentRole == .poster ? "接单人" : "发单人") + "身份？")
            }
        }
    }
}

// 订单统计卡片组件
struct OrderStatsCard: View {
    let title: String
    let count: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// 订单统计数据模型
struct OrderStats {
    let totalOrders: Int
    let completedOrders: Int
    let pendingOrders: Int
}

#Preview {
    ProfileView(currentRole: .constant(.poster))
}