import SwiftUI

struct UserInfoSetupView: View {
    @State private var selectedGender: Gender = .male
    @State private var birthDate = Date()
    @State private var navigateToRoleSelection = false
    private var phoneNumber: String = UserDefaults.standard.string(forKey: UserDefaultsKeys.userPhoneNumber) ?? ""
    
    // 自定义日期格式化器
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }
    
    // 计算年龄
    private var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year ?? 0
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("完善个人信息")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Text("请填写您的基本信息")
                .foregroundColor(.gray)
            
            Spacer()
                .frame(height: 30)
            
            // 性别选择
            VStack(alignment: .leading, spacing: 12) {
                Text("性别")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    ForEach(Gender.allCases.filter { $0 != .all }, id: \.self) { gender in
                        Button(action: { selectedGender = gender }) {
                            HStack(spacing: 8) {
                                Image(systemName: selectedGender == gender ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedGender == gender ? .blue : .gray)
                                Text(gender.rawValue)
                                    .foregroundColor(selectedGender == gender ? .primary : .gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedGender == gender ? Color.blue.opacity(0.1) : Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // 出生日期选择
            VStack(alignment: .leading, spacing: 12) {
                Text("出生日期")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                DatePicker(
                    "",
                    selection: $birthDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, .init(identifier: "zh_CN"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 确认按钮
            Button(action: {
                // 保存用户基本信息
                let userDefaults = UserDefaults.standard
                // 保存基本信息
                userDefaults.set(selectedGender == .male ? "male" : "female", forKey: "userGender")
                userDefaults.set(birthDate, forKey: "userBirthDate")
                
                // 添加测试数据
                userDefaults.set("测试用户", forKey: "userNickname")
                userDefaults.set(phoneNumber, forKey: UserDefaultsKeys.userPhoneNumber)
                userDefaults.set(age, forKey: "userAge")
                userDefaults.set(true, forKey: UserDefaultsKeys.hasCompletedUserInfo)
                
                // 延迟一小段时间后触发导航，确保数据保存完成
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigateToRoleSelection = true
                }
            }) {
                Text("下一步")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
            .disabled(age < 18) // 限制未成年人
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .navigationDestination(isPresented: $navigateToRoleSelection) {
            RoleSelectionView()
        }
    }
}

#Preview {
    NavigationView {
        UserInfoSetupView()
    }
}