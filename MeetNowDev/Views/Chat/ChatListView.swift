import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let partnerName: String
    let lastMessage: String
    let timestamp: Date
    let isOrderCreator: Bool
    let orderId: String
}

struct ChatListView: View {
    @State private var chatMessages: [ChatMessage] = []
    
    var body: some View {
        NavigationView {
            List(chatMessages) { message in
                NavigationLink(
                    destination: ChatDetailView(
                        partnerName: message.partnerName,
                        isOrderCreator: message.isOrderCreator,
                        orderId: message.orderId
                    )
                ) {
                    ChatListItemView(message: message)
                }
            }
            .navigationTitle("聊天列表")
        }
    }
}

struct ChatListItemView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(message.partnerName)
                    .font(.headline)
                Text(message.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(formatDate(message.timestamp))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ChatListView()
}