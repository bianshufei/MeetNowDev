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
    /// 是否显示聊天界面
    @State private var showChatView = false
    /// 是否显示订单确认弹窗
    @State private var showConfirmationAlert = false
    /// 是否显示取消订单弹窗
    @State private var showCancelAlert = false
    /// 是否显示评价视图
    @State private var showRatingView = false
    /// 是否显示接单确认弹窗
    @State private var showTakeOrderAlert = false
    /// 是否正在处理接单请求
    @State private var isProcessingTakeOrder = false
    
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
                    
                    // 操作按钮
                    ActionButtonsSection(
                        order: order,
                        isOrderCreator: isOrderCreator,
                        onChat: { showChatView = true },
                        onConfirm: { showConfirmationAlert = true },
                        onCancel: { showCancelAlert = true },
                        onRate: { showRatingView = true },
                        onTakeOrder: { showTakeOrderAlert = true }
                    )
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
                    isOrderCreator: isOrderCreator
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
        .alert("接单确认", isPresented: $showTakeOrderAlert) {
            Button("确认接单", role: .none) {
                takeOrder()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确认接受该订单吗？接单后需要按约定完成约见。")
        }
        .onAppear {
            loadOrderDetail()
        }
    }
    
    /// 接单操作
    /// 更新订单状态为进行中，并将当前用户设置为接单人
    private func takeOrder() {
        isProcessingTakeOrder = true
        
        // TODO: 实现接单逻辑
        // 1. 调用服务器API接受订单
        // 2. 更新订单状态为进行中
        // 3. 更新接单人信息
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            order?.status = .inProgress
            order?.takerName = "当前用户" // TODO: 替换为实际的用户名
            isProcessingTakeOrder = false
        }
    }
    
    /// 加载订单详情
    /// 从服务器获取指定订单的详细信息
    private func loadOrderDetail() {
        // TODO: 实现从服务器获取订单详情的逻辑
        // 目前使用模拟数据
        order = Order.mockOrders.first { $0.id == orderId }
    }
    
    /// 更新订单状态
    /// - Parameter newStatus: 新的订单状态
    private func updateOrderStatus(_ newStatus: OrderStatus) {
        // TODO: 实现更新订单状态的逻辑
        order?.status = newStatus
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
            // 接单按钮
            if !isOrderCreator && order.status == .pending {
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
            
            // 聊天按钮
            if order.status != .cancelled {
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