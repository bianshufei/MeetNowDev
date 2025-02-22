import SwiftUI

struct ProfileView: View {
    @Binding var currentRole: RoleSelectionView.UserRole
    @State private var showRoleToggleAlert = false
    @State private var userProfile: UserProfile
    @State private var showEditProfile = false
    
    init(currentRole: Binding<RoleSelectionView.UserRole>) {
        _currentRole = currentRole
        _userProfile = State(initialValue: UserProfile.mock) // 使用模拟数据，实际应从用户配置中读取
    }
    
    var body: some View {
        NavigationView {
            List {
                // 用户信息区域
                Section {
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
                    NavigationLink(destination: Text("账户与安全")) {
                        Label("账户与安全", systemImage: "lock.shield")
                    }
                    
                    NavigationLink(destination: Text("隐私设置")) {
                        Label("隐私设置", systemImage: "hand.raised")
                    }
                    
                    NavigationLink(destination: Text("通知设置")) {
                        Label("通知设置", systemImage: "bell")
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

#Preview {
    ProfileView(currentRole: .constant(.poster))
}