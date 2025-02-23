import SwiftUI

/// 聊天详情视图
/// 用于显示与特定用户的聊天界面，支持以下功能：
/// 1. 显示聊天消息列表
/// 2. 发送新消息
/// 3. 虚拟手机号授权和显示
/// 4. 根据用户角色（发单人/接单人）显示不同的导航标题
struct ChatDetailView: View {
    /// 聊天对象的名称
    let partnerName: String
    /// 当前用户是否为订单创建者
    let isOrderCreator: Bool
    
    /// 消息输入框的文本内容
    @State private var messageText = ""
    /// 是否已授权使用虚拟手机号
    @State private var isPhoneNumberAuthorized = false
    /// 是否显示虚拟手机号授权弹窗
    @State private var showPhoneNumberAuthAlert = false
    /// 聊天消息列表
    @State private var messages: [Message] = []
    /// 虚拟手机号，用于保护用户隐私
    @State private var virtualPhoneNumber: String? = nil
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                    }
                }
                .padding()
            }
            
            if isPhoneNumberAuthorized, let phoneNumber = virtualPhoneNumber {
                HStack {
                    Image(systemName: "phone.circle.fill")
                        .foregroundColor(.blue)
                    Text("虚拟号码：\(phoneNumber)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
            } else {
                Button(action: { showPhoneNumberAuthAlert = true }) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.orange)
                        Text("点击授权使用虚拟手机号")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
            }
            
            HStack {
                TextField("输入消息", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
                .disabled(messageText.isEmpty)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle(isOrderCreator ? "与接单人沟通" : "与发单人沟通")
        .onAppear {
            generateVirtualPhoneNumber()
        }
        .alert("虚拟手机号授权", isPresented: $showPhoneNumberAuthAlert) {
            Button("同意") {
                isPhoneNumberAuthorized = true
            }
            Button("暂不需要", role: .cancel) {}
        } message: {
            Text("为保护双方隐私，聊天过程中将使用虚拟手机号。\n授权后，您可以查看对方的虚拟联系方式。")
        }
    }
    
    /// 发送消息
    /// 将当前输入框中的文本作为新消息添加到消息列表中
    /// 发送后会清空输入框
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let newMessage = Message(
            content: messageText,
            isFromCurrentUser: true,
            timestamp: Date()
        )
        messages.append(newMessage)
        messageText = ""
    }
    
    /// 生成虚拟手机号
    /// 为保护用户隐私，生成一个格式为"177****XXXX"的虚拟手机号
    /// 实际应用中应该从服务器获取真实的虚拟号码
    private func generateVirtualPhoneNumber() {
        // 模拟生成虚拟号码
        virtualPhoneNumber = "177****" + String(format: "%04d", Int.random(in: 0...9999))
    }
}

/// 聊天消息模型
/// 用于表示单条聊天消息的数据结构
struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isFromCurrentUser: Bool
    let timestamp: Date
}

/// 消息气泡视图
/// 用于显示单条消息的气泡组件，支持：
/// 1. 根据消息发送者显示不同的气泡样式和位置
/// 2. 显示消息内容和发送时间
struct MessageBubbleView: View {
    let message: Message
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: message.timestamp)
    }
    
    var body: some View {
        VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if message.isFromCurrentUser {
                    Spacer()
                }
                
                Text(message.content)
                    .padding(12)
                    .background(message.isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                    .cornerRadius(16)
                
                if !message.isFromCurrentUser {
                    Spacer()
                }
            }
            
            Text(timeString)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    NavigationView {
        ChatDetailView(partnerName: "测试用户", isOrderCreator: true)
    }
}