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
    @StateObject private var orderService = OrderService.shared
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
        orderService.getOrders(isOrderCreator: isOrderCreator, status: selectedStatusFilter == .all ? nil : selectedStatusFilter)
    }
    
    /// 加载订单列表
    /// 从服务器获取当前用户相关的订单数据
    private func loadOrders() {
        // 订单数据已经由OrderService管理，无需额外加载
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
    let creatorGender: Gender
    let creatorAge: Int
    let activityType: PostOrderView.ActivityType
    let orderType: PostOrderView.OrderType
    
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
            amount: 50.0,
            creatorGender: .male,
            creatorAge: 22,
            activityType: .study,
            orderType: .scheduled
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
            amount: 100.0,
            creatorGender: .male,
            creatorAge: 28,
            activityType: .dining,
            orderType: .scheduled
        ),
        Order(
            id: "3",
            title: "找人一起看展",
            description: "周末去看梵高画展，希望找个对艺术感兴趣的伙伴",
            creatorName: "小红",
            takerName: nil,
            status: .pending,
            dateTime: Date().addingTimeInterval(172800),
            location: "市立美术馆",
            amount: 150.0,
            creatorGender: .female,
            creatorAge: 24,
            activityType: .exhibition,
            orderType: .scheduled
        ),
        Order(
            id: "4",
            title: "即时约饭",
            description: "公司附近找人一起吃午饭",
            creatorName: "小李",
            takerName: nil,
            status: .pending,
            dateTime: Date().addingTimeInterval(3600),
            location: "金融中心美食广场",
            amount: 80.0,
            creatorGender: .male,
            creatorAge: 30,
            activityType: .dining,
            orderType: .instant
        ),
        Order(
            id: "5",
            title: "运动伙伴",
            description: "找人一起打羽毛球",
            creatorName: "小美",
            takerName: nil,
            status: .pending,
            dateTime: Date().addingTimeInterval(7200),
            location: "星光体育馆",
            amount: 60.0,
            creatorGender: .female,
            creatorAge: 25,
            activityType: .sports,
            orderType: .instant
        ),
        Order(
            id: "6",
            title: "咖啡约聊",
            description: "周末下午在咖啡厅聊聊天",
            creatorName: "小婷",
            takerName: nil,
            status: .pending,
            dateTime: Date().addingTimeInterval(259200),
            location: "星巴克咖啡厅",
            amount: 70.0,
            creatorGender: .female,
            creatorAge: 27,
            activityType: .companion,
            orderType: .scheduled
        ),
        Order(
            id: "7",
            title: "逛街购物",
            description: "找人一起去商场逛街，给生活添点乐趣",
            creatorName: "小雨",
            takerName: nil,
            status: .pending,
            dateTime: Date().addingTimeInterval(345600),
            location: "环球购物中心",
            amount: 200.0,
            creatorGender: .female,
            creatorAge: 23,
            activityType: .companion,
            orderType: .scheduled
        )
    ]
}

#Preview {
    NavigationStack {
        OrderManagementView(isOrderCreator: true)
    }
}