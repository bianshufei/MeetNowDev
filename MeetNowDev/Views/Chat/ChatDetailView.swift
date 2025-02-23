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
    /// 消息发送状态
    @State private var isSending = false
    /// 是否显示键盘
    @State private var isKeyboardVisible = false
    /// 消息发送状态
    @State private var messageStatus: [UUID: MessageStatus] = [:]    
    /// 消息发送重试次数
    private let maxRetryCount = 3
    
    /// 消息重试计数
    @State private var messageRetryCount: [UUID: Int] = [:]
    
    /// 是否允许输入消息
    private var isInputEnabled: Bool {
        if let order = orderService.getOrder(by: orderId) {
            return order.status != .cancelled && order.status != .completed
        }
        return false
    }
    
    /// 是否显示确认接单弹窗
    @State private var showConfirmOrderAlert = false
    @State private var showOrderConfirmationAlert = false
    /// 订单ID，用于更新订单状态
    let orderId: String
    @StateObject private var orderService = OrderService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部操作栏
            if let order = orderService.getOrder(by: orderId) {
                if order.status == .pending {
                    HStack(spacing: 16) {
                        // 约见确认按钮
                        Button(action: { 
                            if isOrderCreator {
                                showOrderConfirmationAlert = true
                            } else {
                                showConfirmOrderAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text(isOrderCreator ? "发起约见确认" : "确认约见")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                        }
                        
                        // 虚拟号码按钮
                        Button(action: { showPhoneNumberAuthAlert = true }) {
                            HStack {
                                Image(systemName: "phone.circle")
                                Text("虚拟号码")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(isPhoneNumberAuthorized ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1))
                            .foregroundColor(isPhoneNumberAuthorized ? .gray : .blue)
                            .cornerRadius(8)
                        }
                        .disabled(!isInputEnabled)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .shadow(color: .gray.opacity(0.1), radius: 4, y: 2)
                }
            }
            
            // 聊天消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            if message.isSystemMessage {
                                SystemMessageView(message: message, messages: $messages)
                                    .id(message.id)
                            } else {
                                MessageBubbleView(message: message, status: messageStatus[message.id] ?? .sent)
                                    .id(message.id)
                                    .contextMenu {
                                        if messageStatus[message.id] == .failed {
                                            Button(action: { retryMessage(message) }) {
                                                Label("重试发送", systemImage: "arrow.clockwise")
                                            }
                                            Text("剩余重试次数：\(maxRetryCount - (messageRetryCount[message.id] ?? 0))")
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                    .onChange(of: messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("输入消息", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .disabled(!isInputEnabled || isSending)
                
                Button(action: sendMessage) {
                    if isSending {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.trailing)
                .disabled(!isInputEnabled || messageText.isEmpty || isSending)
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .navigationTitle(isOrderCreator ? "与接单人沟通" : "与发单人沟通")
        .onAppear {
            loadOrderDetail()
            generateVirtualPhoneNumber()
        }
        .alert("虚拟手机号授权", isPresented: $showPhoneNumberAuthAlert) {
            Button("同意") {
                withAnimation {
                    isPhoneNumberAuthorized = true
                }
            }
            Button("暂不需要", role: .cancel) {}
        } message: {
            Text("为保护双方隐私，聊天过程中将使用虚拟手机号。\n授权后，您可以查看对方的虚拟联系方式。")
        }
        .alert("发起约见确认", isPresented: $showOrderConfirmationAlert) {
            Button("确认", role: .destructive) {
                handleOrderConfirmation()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确认发起约见确认？对方同意后将开启约见。")
        }
        .alert("确认约见", isPresented: $showConfirmOrderAlert) {
            Button("确认", role: .destructive) {
                let systemMessage = Message(
                    content: "",
                    isFromCurrentUser: true,
                    timestamp: Date(),
                    isSystemMessage: true,
                    systemMessageType: .orderConfirmation(
                        isCreator: false,
                        status: .accepted
                    ),
                    orderId: orderId
                )
                withAnimation {
                    messages.append(systemMessage)
                }
                
                // 更新订单状态为进行中
                orderService.updateOrderStatus(orderId: orderId, newStatus: .inProgress) { _ in }
                
                // 添加系统通知
                let notificationMessage = Message(
                    content: "",
                    isFromCurrentUser: false,
                    timestamp: Date(),
                    isSystemMessage: true,
                    systemMessageType: .systemNotification(message: "订单状态已更新为进行中"),
                    orderId: orderId
                )
                withAnimation {
                    messages.append(notificationMessage)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确认接受约见？确认后将开启约见。")
        }
    }
    
    /// 重试发送消息
    /// - Parameter message: 需要重试发送的消息
    private func retryMessage(_ message: Message) {
        guard let currentRetryCount = messageRetryCount[message.id], currentRetryCount < maxRetryCount else {
            // 超过最大重试次数
            messageStatus[message.id] = .failed
            return
        }
        
        messageStatus[message.id] = .sending
        messageRetryCount[message.id] = (messageRetryCount[message.id] ?? 0) + 1
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // 模拟成功率随重试次数增加
            let successRate = 0.8 + (Double(messageRetryCount[message.id] ?? 0) * 0.1)
            let isSuccess = Double.random(in: 0...1) > (1 - successRate)
            messageStatus[message.id] = isSuccess ? .sent : .failed
            
            if isSuccess {
                // 发送成功后清除重试计数
                messageRetryCount.removeValue(forKey: message.id)
            }
        }
    }
    
    /// 发送消息
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        isSending = true
        let content = messageText
        messageText = ""
        
        let newMessage = Message(
            content: content,
            isFromCurrentUser: true,
            timestamp: Date()
        )
        messages.append(newMessage)
        messageStatus[newMessage.id] = .sending
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isSending = false
            // 模拟成功率 80%
            let isSuccess = Double.random(in: 0...1) > 0.2
            messageStatus[newMessage.id] = isSuccess ? .sent : .failed
        }
    }
    
    /// 加载订单详情
    private func loadOrderDetail() {
        // 从OrderService获取订单详情
        _ = orderService.getOrder(by: orderId)
    }
    
    /// 生成虚拟手机号并发送系统消息
    private func generateVirtualPhoneNumber() {
        // 模拟生成虚拟号码
        virtualPhoneNumber = "177****" + String(format: "%04d", Int.random(in: 0...9999))
        
        // 添加虚拟号码系统消息
        if let phoneNumber = virtualPhoneNumber {
            let systemMessage = Message(
                content: "",
                isFromCurrentUser: false,
                timestamp: Date(),
                isSystemMessage: true,
                systemMessageType: .virtualPhoneNumber(number: phoneNumber)
            )
            messages.append(systemMessage)
        }
    }
    
    /// 处理约见确认
    private func handleOrderConfirmation() {
        // 添加约见确认消息卡片
        let confirmationMessage = Message(
            content: "",
            isFromCurrentUser: true,
            timestamp: Date(),
            isSystemMessage: false,
            systemMessageType: .orderConfirmation(
                isCreator: isOrderCreator,
                status: .pending
            ),
            orderId: orderId
        )
        withAnimation {
            messages.append(confirmationMessage)
        }
        
        // 禁用约见确认按钮
        showOrderConfirmationAlert = false
    }
}

/// 消息状态枚举
enum MessageStatus {
    case sending   // 发送中
    case sent      // 发送成功
    case failed    // 发送失败
    
    var icon: String {
        switch self {
        case .sending: return "circle.dotted"
        case .sent: return "checkmark"
        case .failed: return "exclamationmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .sending: return .gray
        case .sent: return .green
        case .failed: return .red
        }
    }
}

/// 聊天消息模型
struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    var isSystemMessage: Bool = false
    var systemMessageType: SystemMessageType? = nil
    var orderId: String? = nil
}

enum SystemMessageType {
    case orderConfirmation(isCreator: Bool, status: ConfirmationStatus = .pending)
    case virtualPhoneNumber(number: String)
    case systemNotification(message: String)  // 新增纯系统消息类型
    
    enum ConfirmationStatus {
        case pending
        case accepted
        case rejected
        
        var message: String {
            switch self {
            case .pending: return "等待对方确认"
            case .accepted: return "约见已确认，祝你们约见顺利且有趣，不辜负彼此的勇敢和信任～"
            case .rejected: return "很遗憾对方婉拒了您的约见申请，可以尝试申请其他约见单或发布约见单，找到彼此契合的人"
            }
        }
    }
    
    var title: String {
        switch self {
        case .orderConfirmation(let isCreator, let status):
            if status == .pending {
                return isCreator ? "已向对方发起约见申请" : "收到约见确认申请"
            } else {
                return "约见确认结果"
            }
        case .virtualPhoneNumber:
            return "虚拟号码已开通"
        case .systemNotification:
            return ""
        }
    }
    
    var description: String {
        switch self {
        case .orderConfirmation(let isCreator, let status):
            switch status {
            case .pending:
                return isCreator ? "等待对方确认" : "请选择婉拒或同意约见"
            case .accepted:
                return status.message
            case .rejected:
                return status.message
            }
        case .virtualPhoneNumber(let number):
            return "双方可以通过虚拟号码 (\(number)) 进行通话"
        case .systemNotification(let message):
            return message
        }
    }
    
    var isSystemNotification: Bool {
        if case .systemNotification = self {
            return true
        }
        return false
    }
}

/// 消息气泡视图
struct MessageBubbleView: View {
    let message: Message
    let status: MessageStatus
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: message.timestamp)
    }
    
    var body: some View {
        VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
            HStack(spacing: 16) {
                if !message.isFromCurrentUser {
                    // 对方头像
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 8) {
                    if !message.isFromCurrentUser {
                        Text(message.content)
                            .padding(12)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                    } else {
                        Text(message.content)
                            .padding(12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        
                        Image(systemName: status.icon)
                            .foregroundColor(status.color)
                            .font(.caption)
                    }
                }
                
                if message.isFromCurrentUser {
                    // 自己的头像
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            Text(timeString)
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
        }
    }
}

// 用于设置特定圆角的ViewModifier
struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                               byRoundingCorners: corners,
                               cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        modifier(CornerRadiusStyle(radius: radius, corners: corners))
    }
}

#Preview {
    NavigationView {
        ChatDetailView(partnerName: "测试用户", isOrderCreator: true, orderId: "test-order-id")
    }
}