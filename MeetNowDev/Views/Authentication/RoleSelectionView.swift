import SwiftUI

struct RoleSelectionView: View {
    @State private var selectedRole: UserRole? = nil
    @State private var navigateToMain = false
    
    enum UserRole {
        case poster // 发单人
        case taker // 接单人
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("选择您的角色")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Text("请选择您想要使用的身份")
                .foregroundColor(.gray)
            
            Spacer()
                .frame(height: 50)
            
            // 发单人选项
            RoleOptionButton(
                title: "发单人",
                description: "发布约见需求",
                icon: "square.and.pencil",
                isSelected: selectedRole == .poster,
                gradient: Gradient(colors: [.orange, .orange.opacity(0.8)]),
                action: { selectedRole = .poster }
            )
            
            // 接单人选项
            RoleOptionButton(
                title: "接单人",
                description: "接受约见邀请",
                icon: "person.2.fill",
                isSelected: selectedRole == .taker,
                gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                action: { selectedRole = .taker }
            )
            
            Spacer()
            
            // 确认按钮
            Button(action: {
                if let role = selectedRole {
                    let userDefaults = UserDefaults.standard
                    // 保存用户角色选择
                    userDefaults.set(role == .poster ? "poster" : "taker", forKey: "userRole")
                    // 保存用户角色选择状态
                    userDefaults.set(true, forKey: "hasSelectedRole")
                    
                    // 创建用户配置文件
                    let _ = UserProfile(
                        nickname: UserDefaults.standard.string(forKey: "userNickname") ?? "",
                        phoneNumber: UserDefaults.standard.string(forKey: UserDefaultsKeys.userPhoneNumber) ?? "",
                        gender: UserDefaults.standard.string(forKey: "userGender") == "male" ? .male : .female,
                        age: UserDefaults.standard.integer(forKey: "userAge"),
                        role: role
                    )
                    
                    navigateToMain = true
                }
            }) {
                Text("确认")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        selectedRole == .poster ?
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .orange.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(selectedRole == nil)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
        .navigationDestination(isPresented: $navigateToMain) {
            MainView()
        }
    }
}

// 角色选项按钮组件
struct RoleOptionButton: View {
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let gradient: Gradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ?
                          LinearGradient(gradient: gradient,
                                        startPoint: .leading,
                                        endPoint: .trailing) :
                          LinearGradient(gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray6)]),
                                        startPoint: .leading,
                                        endPoint: .trailing))
            )
        }
        .padding(.horizontal)
    }
}

#Preview {
    RoleSelectionView()
}