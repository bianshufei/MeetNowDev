import SwiftUI

struct LoginView: View {
    @State private var phoneNumber: String = ""
    @State private var isLoading: Bool = false
    @State private var showInvalidPhoneAlert: Bool = false
    @State private var navigateToRoleSelection: Bool = false
    
    // 验证手机号格式
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let pattern = "^1[3-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: phone)
    }
    
    var body: some View {
        NavigationView {
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
                        // 模拟登录过程
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isLoading = false
                            navigateToRoleSelection = true
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
            .navigationDestination(isPresented: $navigateToRoleSelection) {
                UserInfoSetupView()
            }
        }
    }
}

#Preview {
    LoginView()
}