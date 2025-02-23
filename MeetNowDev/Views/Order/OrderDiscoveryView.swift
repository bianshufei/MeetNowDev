import SwiftUI

struct OrderDiscoveryView: View {
    @State private var selectedGender: Gender = .all
    @State private var selectedAgeRange: AgeRange = .young
    @State private var selectedOrderId: String? = nil
    @State private var showOrderDetail = false
    @State private var isRefreshing = false
    @StateObject private var orderService = OrderService.shared
    
    enum AgeRange: String, CaseIterable {
        case young = "18-25岁"
        case mature = "26-35岁"
        
        var range: ClosedRange<Int> {
            switch self {
            case .young: return 18...25
            case .mature: return 26...35
            }
        }
        
        static func fromAge(_ age: Int) -> AgeRange {
            if age >= 18 && age <= 25 {
                return .young
            } else {
                return .mature
            }
        }
    }
    
    var filteredOrders: [Order] {
        var orders = orderService.getOrders(isOrderCreator: false, status: .pending)
        
        // 性别筛选
        if selectedGender != .all {
            orders = orders.filter { order in
                return order.creatorGender == selectedGender
            }
        }
        
        // 年龄筛选
        orders = orders.filter { order in
            return selectedAgeRange.range.contains(order.creatorAge)
        }
        
        return orders
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 筛选条件栏
                HStack(spacing: 16) {
                    // 性别筛选
                    Menu {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Button(action: { selectedGender = gender }) {
                                HStack {
                                    Text(gender.rawValue)
                                    if selectedGender == gender {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    } label: {
                        FilterButton(title: "性别", value: selectedGender.rawValue)
                    }
                    
                    // 年龄筛选
                    Menu {
                        ForEach(AgeRange.allCases, id: \.self) { range in
                            Button(action: { selectedAgeRange = range }) {
                                HStack {
                                    Text(range.rawValue)
                                    if selectedAgeRange == range {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    } label: {
                        FilterButton(title: "年龄", value: selectedAgeRange.rawValue)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, y: 5)
                
                // 订单列表
                RefreshableScrollView(isRefreshing: $isRefreshing) {
                    await refreshOrders()
                } content: {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredOrders) { order in
                            OrderCard(order: order) {
                                checkAndShowOrderDetail(order)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        hideOrder(order)
                                    }
                                } label: {
                                    Label("隐藏", systemImage: "eye.slash")
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("发现可参与的约见")
            .navigationDestination(isPresented: $showOrderDetail) {
                if let orderId = selectedOrderId {
                    OrderDetailView(orderId: orderId, isOrderCreator: false)
                }
            }
            .onAppear {
                Task {
                    await refreshOrders()
                }
            }
        }
    }
    
    private func refreshOrders() async {
        // 模拟从服务器获取最新订单列表
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // 刷新完成后更新UI
        await MainActor.run {
            // 使用updateOrders方法更新订单列表
            orderService.updateOrders(Order.mockOrders)
            isRefreshing = false
        }
    }
    
    private func hideOrder(_ order: Order) {
        // 从订单列表中移除该订单
        var currentOrders = orderService.getOrders(isOrderCreator: false, status: .pending)
        currentOrders.removeAll { $0.id == order.id }
        orderService.updateOrders(currentOrders)
    }
    
    private func checkAndShowOrderDetail(_ order: Order) {
        // 检查订单状态
        if let updatedOrder = orderService.getOrder(by: order.id) {
            if updatedOrder.status != .pending {
                // TODO: 实现提示弹窗
                return
            }
            selectedOrderId = updatedOrder.id
            showOrderDetail = true
        }
    }
}

// 筛选按钮组件
struct FilterButton: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .foregroundColor(.gray)
            Text(value)
                .foregroundColor(.primary)
            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// 订单卡片组件
struct OrderCard: View {
    let order: Order
    let onViewDetail: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 订单头部信息
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(order.creatorName)
                            .font(.headline)
                        Text(order.creatorGender == .male ? "♂" : "♀")
                            .foregroundColor(order.creatorGender == .male ? .blue : .pink)
                            .font(.headline)
                    }
                    Text(order.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // 订单内容
            VStack(alignment: .leading, spacing: 12) {
                // 活动类型和订单类型标签
                HStack {
                    Label("吃饭", systemImage: "fork.knife")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Label(
                        order.dateTime.timeIntervalSince(Date()) < 3600 ? "即时约见" : "预约约见",
                        systemImage: order.dateTime.timeIntervalSince(Date()) < 3600 ? "clock.fill" : "calendar"
                    )
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("15分钟前发布")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // 补充说明
                if !order.description.isEmpty {
                    Text(order.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
                
                // 时间信息
                Label(
                    order.formattedDateTime,
                    systemImage: "clock"
                )
                .font(.subheadline)
                .foregroundColor(.primary)
                
                // 活动预算
                Label(
                    "活动预算：¥\(String(format: "%.2f", order.amount))",
                    systemImage: "creditcard"
                )
                .font(.subheadline)
                .foregroundColor(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            // 查看详情按钮
            Button(action: onViewDetail) {
                HStack {
                    Image(systemName: "doc.text")
                    Text("查看详情")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
}

#Preview {
    OrderDiscoveryView()
}