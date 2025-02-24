import SwiftUI

struct EditProfileView: View {
    @Binding var userProfile: UserProfile
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @Environment(\.dismiss) private var dismiss
    init(userProfile: Binding<UserProfile>) {
        _userProfile = userProfile
    }
    
    var body: some View {
        Form {
            Section {
                // 头像选择
                HStack {
                    Text("头像")
                    Spacer()
                    Button(action: {
                        showImagePicker = true
                    }) {
                        if let avatarUrl = userProfile.avatarUrl {
                            AsyncImage(url: URL(string: avatarUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // 昵称输入
                TextField("昵称", text: $userProfile.nickname)
                
                // 性别选择
                Picker("性别", selection: $userProfile.gender) {
                    ForEach([Gender.male, .female], id: \.self) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                
                // 年龄选择
                Stepper("年龄: \(userProfile.age)", value: $userProfile.age, in: 18...100)
            }
        }
        .navigationTitle("编辑资料")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    // TODO: 保存用户信息
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
                .onChange(of: selectedImage) { oldImage, newImage in
                    if let _ = newImage {
                        // 在实际应用中，这里应该先上传图片到服务器，获取URL
                        // 这里为了演示，我们使用一个模拟的URL
                        userProfile.avatarUrl = "https://example.com/avatar.jpg"
                    }
                }
        }
    }
}

#Preview {
    NavigationView {
        EditProfileView(userProfile: .constant(UserProfile.mock))
    }
}