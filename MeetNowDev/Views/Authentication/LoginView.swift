import SwiftUI

/// 登录视图
/// 用户通过手机号一键登录系统
/// 功能包括：
/// 1. 手机号格式验证
/// 2. 登录状态管理
/// 3. 用户协议展示
/// 4. 登录成功后跳转到用户信息设置页面

enum UserDefaultsKeys {
    static let userPhoneNumber = "userPhoneNumber"
    static let hasCompletedUserInfo = "hasCompletedUserInfo"
}

struct LoginView: View {
    /// 用户输入的手机号
    @State private var phoneNumber: String = ""
    /// 登录加载状态
    @State private var isLoading: Bool = false
    /// 控制手机号格式错误提示的显示状态
    @State private var showInvalidPhoneAlert: Bool = false
    /// 导航路径管理
    @State private var navigationPath = NavigationPath()
    
    /// 验证手机号格式是否符合要求
    /// - Parameter phone: 待验证的手机号
    /// - Returns: 手机号是否有效
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let pattern = "^1[3-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: phone)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 30) {
                // Logo区域
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 80)
                
                Text("MeetNowDev")
                    .font(.title)
                    .fontWeight(.bold)
                
                // 手机号输入区域
                VStack(alignment: .leading, spacing: 8) {
                    Text("手机号")
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("+86")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                        
                        TextField("请输入手机号", text: $phoneNumber)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // 登录按钮
                Button(action: {
                    if isValidPhoneNumber(phoneNumber) {
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            UserDefaults.standard.set(phoneNumber, forKey: UserDefaultsKeys.userPhoneNumber)
                            isLoading = false
                            navigationPath.append(true)
                        }
                    } else {
                        showInvalidPhoneAlert = true
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("一键登录")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(phoneNumber.isEmpty || isLoading)
                
                Spacer()
                
                // 底部说明文字
                VStack(spacing: 8) {
                    Text("登录即代表同意《用户协议》和《隐私政策》")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Text("©2023 MeetNow. All rights reserved.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
            }
            .alert("提示", isPresented: $showInvalidPhoneAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text("请输入正确的手机号码")
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Bool.self) { _ in
                UserInfoSetupView()
            }
        }
    }
}

#Preview {
    LoginView()
}