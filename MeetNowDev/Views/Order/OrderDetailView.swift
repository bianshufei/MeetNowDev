import SwiftUI

/// 订单详情视图
/// 用于展示订单的详细信息，支持以下功能：
/// 1. 显示订单的完整信息
/// 2. 根据用户角色（发单人/接单人）显示不同的操作按钮
/// 3. 订单状态更新
/// 4. 订单履约确认
/// 5. 发起与对方的聊天
struct OrderDetailView: View {
    /// 订单ID
    let orderId: String
    /// 当前用户是否为订单创建者
    let isOrderCreator: Bool
    
    /// 订单详情数据
    @State private var order: Order? = nil
    @StateObject private var orderService = OrderService.shared
    
    /// 是否显示聊天界面
    @State private var showChatView = false
    /// 是否显示订单确认弹窗
    @State private var showConfirmationAlert = false
    /// 是否显示取消订单弹窗
    @State private var showCancelAlert = false
    /// 是否显示评价视图
    @State private var showRatingView = false
    
    var body: some View {
        ScrollView {
            if let order = order {
                VStack(alignment: .leading, spacing: 20) {
                    // 订单状态卡片
                    StatusCard(status: order.status)
                    
                    // 订单基本信息
                    OrderInfoSection(order: order)
                    
                    // 订单描述
                    OrderDescriptionSection(description: order.description)
                    
                    // 用户信息
                    UserInfoSection(
                        name: isOrderCreator ? (order.takerName ?? "等待接单") : order.creatorName,
                        role: isOrderCreator ? "接单人" : "发单人"
                    )
                    
                    // 聊天按钮
                    if order.status != .cancelled {
                        Button(action: { showChatView = true }) {
                            HStack {
                                Image(systemName: "message")
                                Text("联系\(isOrderCreator ? "接单人" : "发单人")")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    // 确认完成按钮（仅在进行中状态显示）
                    if order.status == .inProgress {
                        Button(action: { showConfirmationAlert = true }) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("确认完成")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    // 评价按钮（仅在已完成状态显示）
                    if order.status == .completed {
                        Button(action: { showRatingView = true }) {
                            HStack {
                                Image(systemName: "star")
                                Text("评价约见")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    // 取消订单按钮
                    if order.status == .pending || (order.status == .inProgress && isOrderCreator) {
                        Button(action: { showCancelAlert = true }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("取消订单")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            } else {
                ProgressView()
                    .padding()
            }
        }
        .navigationTitle("订单详情")
        .navigationDestination(isPresented: $showChatView) {
            if let order = order {
                ChatDetailView(
                    partnerName: isOrderCreator ? (order.takerName ?? "接单人") : order.creatorName,
                    isOrderCreator: isOrderCreator,
                    orderId: order.id
                )
            }
        }
        .navigationDestination(isPresented: $showRatingView) {
            if let order = order {
                OrderRatingView(orderId: order.id, isOrderCreator: isOrderCreator)
            }
        }
        .alert("确认完成", isPresented: $showConfirmationAlert) {
            Button("确认", role: .destructive) {
                updateOrderStatus(.completed)
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确认该订单已完成？")
        }
        .alert("取消订单", isPresented: $showCancelAlert) {
            Button("确认", role: .destructive) {
                updateOrderStatus(.cancelled)
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确认取消该订单？")
        }
        .onAppear {
            loadOrderDetail()
        }
    }
    
    /// 加载订单详情
    /// 从服务器获取指定订单的详细信息
    private func loadOrderDetail() {
        order = orderService.getOrder(by: orderId)
    }
    
    /// 更新订单状态
    /// - Parameter newStatus: 新的订单状态
    private func updateOrderStatus(_ newStatus: OrderStatus) {
        orderService.updateOrderStatus(orderId: orderId, newStatus: newStatus) { result in
            switch result {
            case .success:
                // 更新本地订单数据
                order = orderService.getOrder(by: orderId)
                // TODO: 发送系统消息到聊天界面
                _ = "订单状态已更新为：\(newStatus.displayName)"
            case .failure(let error):
                // TODO: 显示错误提示
                print(error.localizedDescription)
            }
        }
    }
}

/// 状态卡片视图
/// 用于显示当前订单状态
struct StatusCard: View {
    let status: OrderStatus
    
    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(status.color)
            Text(status.displayName)
                .font(.headline)
            Spacer()
        }
        .padding()
        .background(status.color.opacity(0.1))
        .cornerRadius(10)
    }
}

/// 订单信息区域
/// 显示订单的基本信息，如时间、地点、金额等
struct OrderInfoSection: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("订单信息")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                OrderInfoRow(icon: "calendar", text: order.formattedDateTime)
                OrderInfoRow(icon: "mappin.circle", text: order.location)
                OrderInfoRow(icon: "dollarsign.circle", text: "¥\(String(format: "%.2f", order.amount))")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

/// 订单描述区域
/// 显示订单的详细描述信息
struct OrderDescriptionSection: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("订单描述")
                .font(.headline)
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

/// 用户信息区域
/// 显示订单相关用户的信息
struct UserInfoSection: View {
    let name: String
    let role: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("用户信息")
                .font(.headline)
            
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.body)
                    Text(role)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

/// 操作按钮区域
/// 根据用户角色和订单状态显示不同的操作按钮
struct ActionButtonsSection: View {
    let order: Order
    let isOrderCreator: Bool
    let onChat: () -> Void
    let onConfirm: () -> Void
    let onCancel: () -> Void
    let onRate: () -> Void
    let onTakeOrder: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 接单按钮和沟通按钮
            if !isOrderCreator && order.status == .pending {
                VStack(spacing: 12) {
                    Button(action: onChat) {
                        HStack {
                            Image(systemName: "message")
                            Text("与发单人沟通")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: onTakeOrder) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("确认接单")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .opacity(0.6)
                    .overlay(
                        VStack(spacing: 4) {
                            Text("请先与发单人沟通")
                                .font(.caption)
                            Text("达成一致后再接单")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        , alignment: .bottom
                    )
                }
            }
            
            // 聊天按钮
            if order.status != .cancelled && (isOrderCreator || order.status == .inProgress) {
                Button(action: onChat) {
                    HStack {
                        Image(systemName: "message")
                        Text("联系\(isOrderCreator ? "接单人" : "发单人")")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            // 确认完成按钮
            if order.status == .inProgress {
                Button(action: onConfirm) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("确认完成")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            // 评价按钮
            if order.status == .completed {
                Button(action: onRate) {
                    HStack {
                        Image(systemName: "star")
                        Text("评价约见")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            // 取消订单按钮
            if order.status == .pending || (order.status == .inProgress && isOrderCreator) {
                Button(action: onCancel) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("取消订单")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OrderDetailView(orderId: "1", isOrderCreator: true)
    }
}