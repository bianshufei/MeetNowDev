import SwiftUI

/// 订单管理视图
/// 用于管理用户的订单列表，支持以下功能：
/// 1. 根据用户角色（发单人/接单人）显示不同的订单列表
/// 2. 订单状态跟踪和更新
/// 3. 订单详情查看
/// 4. 订单履约确认
struct OrderManagementView: View {
    /// 当前用户是否为订单创建者
    let isOrderCreator: Bool
    
    /// 订单列表数据
    @State private var orders: [Order] = []
    /// 选中的订单状态过滤器
    @State private var selectedStatusFilter: OrderStatus = .all
    /// 是否显示订单详情
    @State private var showOrderDetail = false
    /// 选中的订单ID
    @State private var selectedOrderId: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 状态过滤器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(OrderStatus.allCases, id: \.self) { status in
                        StatusFilterButton(
                            status: status,
                            isSelected: selectedStatusFilter == status,
                            action: { selectedStatusFilter = status }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
            .shadow(color: .gray.opacity(0.2), radius: 4, y: 2)
            
            // 订单列表
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredOrders) { order in
                        OrderManagementCard(order: order, isOrderCreator: isOrderCreator)
                            .onTapGesture {
                                selectedOrderId = order.id
                                showOrderDetail = true
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(isOrderCreator ? "我发布的" : "我接受的")
        .navigationDestination(isPresented: $showOrderDetail) {
            if let orderId = selectedOrderId {
                OrderDetailView(orderId: orderId, isOrderCreator: isOrderCreator)
            }
        }
        .onAppear {
            loadOrders()
        }
    }
    
    /// 根据状态过滤订单列表
    private var filteredOrders: [Order] {
        if selectedStatusFilter == .all {
            return orders
        }
        return orders.filter { $0.status == selectedStatusFilter }
    }
    
    /// 加载订单列表
    /// 从服务器获取当前用户相关的订单数据
    private func loadOrders() {
        // TODO: 实现从服务器获取订单列表的逻辑
        // 目前使用模拟数据
        orders = Order.mockOrders
    }
}

/// 订单状态过滤按钮
/// 用于在订单列表顶部显示状态过滤选项
struct StatusFilterButton: View {
    var status: OrderStatus
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(status.displayName)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

/// 订单卡片视图
/// 用于在列表中展示单个订单的概要信息
struct OrderManagementCard: View {
    let order: Order
    let isOrderCreator: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 订单标题和状态
            HStack {
                Text(order.title)
                    .font(.headline)
                Spacer()
                Text(order.status.displayName)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(order.status.color.opacity(0.1))
                    .foregroundColor(order.status.color)
                    .cornerRadius(8)
            }
            
            // 订单详细信息
            VStack(alignment: .leading, spacing: 8) {
                OrderInfoRow(icon: "calendar", text: order.formattedDateTime)
                OrderInfoRow(icon: "mappin.circle", text: order.location)
                OrderInfoRow(icon: "person.circle", text: isOrderCreator ? "接单人：\(order.takerName ?? "暂无")" : "发单人：\(order.creatorName)")
            }
            
            // 订单金额
            HStack {
                Spacer()
                Text("¥\(String(format: "%.2f", order.amount))")
                    .font(.title3)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

/// 订单信息行
/// 用于在订单卡片中显示具体的订单信息项
struct OrderInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

/// 订单状态枚举
/// 用于表示订单的不同状态
enum OrderStatus: String, CaseIterable {
    case all = "全部"
    case pending = "待接单"
    case inProgress = "进行中"
    case completed = "已完成"
    case cancelled = "已取消"
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .all: return .gray
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

/// 订单模型
/// 用于表示单个订单的数据结构
struct Order: Identifiable {
    let id: String
    let title: String
    let description: String
    let creatorName: String
    var takerName: String?
    var status: OrderStatus
    let dateTime: Date
    let location: String
    let amount: Double
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: dateTime)
    }
}

// MARK: - 预览数据
extension Order {
    static var mockOrders: [Order] = [
        Order(
            id: "1",
            title: "寻找学习伙伴",
            description: "找人一起去图书馆学习",
            creatorName: "张三",
            takerName: "李四",
            status: .inProgress,
            dateTime: Date(),
            location: "市中心图书馆",
            amount: 50.0
        ),
        Order(
            id: "2",
            title: "约饭聊天",
            description: "周末一起吃饭聊天",
            creatorName: "王五",
            takerName: nil,
            status: .pending,
            dateTime: Date().addingTimeInterval(86400),
            location: "海底捞火锅店",
            amount: 100.0
        )
    ]
}

#Preview {
    NavigationStack {
        OrderManagementView(isOrderCreator: true)
    }
}