import SwiftUI

/// 系统消息视图
/// 用于显示系统消息，包括约见确认、虚拟手机号等信息
/// 采用居中小字的样式展示
struct SystemMessageView: View {
    let message: Message
    @Binding var messages: [Message]
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: message.timestamp)
    }
    
    var body: some View {
        if let systemType = message.systemMessageType {
            VStack(spacing: 8) {
                if case .orderConfirmation(let isCreator, let status) = systemType {
                    // 约见确认消息卡片
                    VStack(spacing: 8) {
                        Text(isCreator ? "已发起约见申请" : "收到约见申请")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Text(isCreator ? "等待对方确认" : "请选择接受或婉拒")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        if !isCreator && status == .pending {
                            // 显示接收方的确认按钮
                            HStack(spacing: 16) {
                                Button(action: {
                                    handleOrderConfirmation(accept: true)
                                }) {
                                    Text("接受")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .frame(width: 80)
                                        .padding(.vertical, 8)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    handleOrderConfirmation(accept: false)
                                }) {
                                    Text("婉拒")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .frame(width: 80)
                                        .padding(.vertical, 8)
                                        .background(Color.red)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                } else if case .systemNotification(let message) = systemType {
                    // 系统通知消息
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
        }
    }
    
    /// 处理约见确认的响应
    /// - Parameter accept: 是否同意约见
    private func handleOrderConfirmation(accept: Bool) {
        // 添加新的确认结果消息
        let resultMessage = Message(
            content: "",
            isFromCurrentUser: false,
            timestamp: Date(),
            isSystemMessage: true,
            systemMessageType: .systemNotification(
                message: accept ? 
                    "约见已确认，祝你们约见顺利且有趣，不辜负彼此的勇敢和信任～" :
                    "很遗憾对方婉拒了您的约见申请，可以尝试申请其他约见单或发布约见单，找到彼此契合的人"
            ),
            orderId: message.orderId
        )
        withAnimation {
            messages.append(resultMessage)
        }
        
        if let orderId = message.orderId {
            if accept {
                // 如果同意约见，更新订单状态为进行中
                OrderService.shared.updateOrderStatus(orderId: orderId, newStatus: .inProgress) { _ in }
            }
        }
    }
}