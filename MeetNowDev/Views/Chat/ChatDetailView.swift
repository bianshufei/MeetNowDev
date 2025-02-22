import SwiftUI

struct ChatDetailView: View {
    let partnerName: String
    let isOrderCreator: Bool
    
    @State private var messageText = ""
    @State private var messages: [Message] = []
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
            
            if let phoneNumber = virtualPhoneNumber {
                HStack {
                    Image(systemName: "phone.circle.fill")
                        .foregroundColor(.blue)
                    Text("虚拟号码：\(phoneNumber)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
    }
    
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
    
    private func generateVirtualPhoneNumber() {
        // 模拟生成虚拟号码
        virtualPhoneNumber = "177****" + String(format: "%04d", Int.random(in: 0...9999))
    }
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isFromCurrentUser: Bool
    let timestamp: Date
}

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
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
    }
}

#Preview {
    NavigationView {
        ChatDetailView(partnerName: "测试用户", isOrderCreator: true)
    }
}